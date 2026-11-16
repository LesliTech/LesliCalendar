require "test_helper"

module LesliCalendar
    class EventContractTest < LesliTesting::ModelTester
        setup do
            @core = Lesli::Account.create!(name: "Calendar", email: "calendar-contract@example.test", status: :active)
            @foreign = Lesli::Account.create!(name: "Other", email: "calendar-other@example.test", status: :active)
            @user = create_user(@core, "calendar-author@example.test")
            @other_user = create_user(@foreign, "calendar-other-user@example.test")
            @event = @core.calendar.events.build(
                calendar: @core.calendar.default_calendar, user: @user,
                title: " Planning ", start_at: Time.current, end_at: 1.hour.from_now
            )
        end

        test "defaults and explicit associations match the local account contract" do
            assert @event.valid?, @event.errors.full_messages.to_sentence
            assert_equal "Planning", @event.title
            assert @event.scheduled?
            assert_not @event.public?
            assert_equal "lesli_calendar_events", Event.table_name
            assert_equal "lesli_calendar_event_attendants", Event::Attendant.table_name
            assert_equal "lesli_calendar_event_user_invitations", Event::UserInvitation.table_name
            assert_equal "lesli_calendar_event_role_invitations", Event::RoleInvitation.table_name
            assert_equal Account, Event.reflect_on_association(:account).klass
            assert_equal "default", @event.calendar.name
            assert_equal "0d52bf", @event.calendar.color
        end

        test "requires content organizer calendar and both valid dates" do
            [:title, :user, :calendar, :account, :start_at, :end_at].each do |attribute|
                invalid = @event.dup
                invalid.public_send("#{attribute}=", nil)
                assert_not invalid.valid?, attribute.to_s
                assert invalid.errors[attribute].present?
            end
            [:start_at, :end_at].each do |attribute|
                invalid = @event.dup
                invalid.public_send("#{attribute}=", "invalid date")
                assert_not invalid.valid?
                assert invalid.errors.added?(attribute, :invalid)
            end
            [@event.start_at, @event.start_at - 1.second].each do |finish|
                @event.end_at = finish
                assert_not @event.valid?
                assert @event.errors[:end_at].present?
            end
        end

        test "validates status privacy destinations and account relations" do
            @event.assign_attributes(status: "approved", public: nil, user: @other_user, calendar: @foreign.calendar.default_calendar)
            assert_not @event.valid?
            [:status, :public, :user, :calendar].each { |attribute| assert @event.errors[attribute].present? }
            @event.assign_attributes(status: "scheduled", public: false, user: @user, calendar: @core.calendar.default_calendar)
            [nil, "", "/support?open=true", "https://example.test/meeting", "http://example.test"].each do |url|
                @event.url = url
                assert @event.valid?, url.to_s
            end
            ["javascript:alert(1)", "//example.test", "/\\example.test", "https:", "bad link"].each do |url|
                @event.url = url
                assert_not @event.valid?, url
            end
        end

        test "calendar lookup honors the ID and explicit default name" do
            calendar = @core.calendar.default_calendar
            @core.calendar.initialize_engine
            assert_equal 1, @core.calendar.calendars.count
            assert_equal calendar, CalendarService.new(@user).find_default.result
            assert_equal calendar, CalendarService.new(@user).find(calendar.id).result
            assert_not CalendarService.new(@user).find(@foreign.calendar.default_calendar.id).found?
            assert_not CalendarService.new(@user).find(-1).found?
            assert_not @core.calendar.calendars.build(name: "default").valid?
            assert_equal calendar, @event.calendar
        end

        test "invitations are unique and restricted to the event account" do
            @event.save!
            role = @core.roles.first!
            @event.user_invitations.create!(user: @user)
            @event.role_invitations.create!(role: role)
            assert_equal [@user], @event.invited_users.to_a
            assert_equal [role], @event.invited_roles.to_a
            assert_not @event.user_invitations.build(user: @user).valid?
            assert_not @event.role_invitations.build(role: role).valid?
            assert_not @event.user_invitations.build(user: @other_user).valid?
            assert_not @event.role_invitations.build(role: @foreign.roles.first!).valid?
        end

        test "responses require a same account user and a timestamp matching the state" do
            @event.save!
            response = @event.attendants.build(user: @user)
            assert response.response_pending?
            assert response.valid?
            response.response = :accepted
            assert_not response.valid?
            response.responded_at = Time.current
            response.save!
            assert_not @event.attendants.build(user: @user).valid?
            assert_not @event.attendants.build(user: @other_user).valid?
            response.update!(response: :declined)
            response.assign_attributes(response: :pending)
            assert_not response.valid?
            response.update!(responded_at: nil)
            assert response.response_pending?
            assert_not Event::Attendant.column_names.include?("deleted_at")
            assert_not Event::Attendant.column_names.include?("confirmed_at")
        end

        test "cancelled and soft deleted events preserve their invitations and responses" do
            @event.save!
            @event.user_invitations.create!(user: @user)
            @event.role_invitations.create!(role: @core.roles.first!)
            @event.attendants.create!(user: @user, response: :accepted, responded_at: Time.current)
            @event.update!(status: :cancelled)
            @event.destroy!
            assert_not Event.exists?(@event.id)
            assert Event.with_deleted.find(@event.id).cancelled?
            assert_equal 1, Event::UserInvitation.where(event_id: @event.id).count
            assert_equal 1, Event::RoleInvitation.where(event_id: @event.id).count
            assert_equal 1, Event::Attendant.where(event_id: @event.id).count
        end

        test "database constraints reject missing references duplicate invitations and invalid intervals" do
            @event.save!
            invalid_update = ->(attributes) do
                assert_raises(ActiveRecord::StatementInvalid) do
                    Event.transaction(requires_new: true) { Event.where(id: @event.id).update_all(attributes) }
                end
            end
            %i[title user_id calendar_id account_id start_at end_at status public].each { |key| invalid_update.call(key => nil) }
            invalid_update.call(end_at: @event.start_at)
            invalid_update.call(status: "approved")
            invalid_update.call(calendar_id: -1)
            [[Event::UserInvitation, :user_id, @user.id],
             [Event::RoleInvitation, :role_id, @core.roles.first!.id],
             [Event::Attendant, :user_id, @user.id]].each do |model, key, id|
                attributes = { event_id: @event.id, key => id }
                attributes[:response] = "pending" if model == Event::Attendant
                model.insert_all!([attributes])
                assert_raises(ActiveRecord::RecordNotUnique) do
                    Event.transaction(requires_new: true) { model.insert_all!([attributes]) }
                end
                assert_raises(ActiveRecord::NotNullViolation) do
                    Event.transaction(requires_new: true) { model.insert_all!([attributes.merge(key => nil)]) }
                end
                assert_raises(ActiveRecord::InvalidForeignKey) do
                    Event.transaction(requires_new: true) { model.insert_all!([attributes.merge(event_id: -1)]) }
                end
            end

        end

        test "service returns validation failures after the contract is enforced" do
            service = EventService.new(@user).create(title: "")
            assert_not service.successful?
            assert service.result.errors[:start_at].present?
            assert_not service.result.persisted?
        end
        private

        def create_user(account, email)
            user = account.users.new(email: email)
            if user.respond_to?(:password=)
                user.password = "Password123!"
                user.confirmed_at = Time.current
            end
            user.save!
            user
        end
    end
end
