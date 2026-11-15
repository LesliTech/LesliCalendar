require "test_helper"

module LesliCalendar
    class EventOperationsTest < LesliTesting::ModelTester
        setup do
            @account = Lesli::Account.create!(name: "Operations", email: "operations@example.test", status: :active)
            @other_account = Lesli::Account.create!(name: "Outside", email: "outside@example.test", status: :active)
            @author = create_user(@account, "author")
            @reader = create_user(@account, "reader")
            @outsider = create_user(@other_account, "outside")
        end

        def create_user(account, name)
            user = account.users.new(email: "#{name}-operations@example.test")
            if user.respond_to?(:password=)
                user.password = "Password123!"
                user.confirmed_at = Time.current
            end
            user.save!
            user
        end

        def create_event(**attributes)
            service = EventService.new(@author).create({ title: "Planning", start_at: 1.hour.from_now, end_at: 2.hours.from_now }.merge(attributes))
            assert service.successful?, service.errors_as_sentence
            service.result
        end

        def update_event(event, **attributes)
            EventService.new(@author).show(event.id).update(attributes)
        end

        def respond_to_event(event, response, user = @reader)
            EventResponseOperator.new(user, event.id).operate(response: response)
        end

        test "CRUD owns identity and scopes all lookups" do
            event = create_event(user_id: @outsider.id, account_id: @other_account.calendar.id, calendar_id: @other_account.calendar.default_calendar.id, status: "cancelled")
            assert_equal @author, event.user
            assert_equal @account.calendar, event.account
            assert_equal @account.calendar.default_calendar, event.calendar
            assert event.scheduled?
            assert_includes EventService.new(@author).index.result, event
            assert_not_includes EventService.new(@reader).index.result, event
            assert_raises(ActiveRecord::RecordNotFound) { EventService.new(@reader).show(event.id) }
            assert_raises(ActiveRecord::RecordNotFound) { EventService.new(@outsider).find(event.id) }
            assert_raises(ActiveRecord::RecordNotFound) { EventService.new(@author).show(-1) }
            service = update_event(event, title: "Changed", user_id: @reader.id, status: "cancelled")
            assert service.successful?
            assert_equal "Changed", event.reload.title
            assert_equal @author, event.user
            assert event.scheduled?
        end

        test "public viewers and private invitees cannot edit or delete" do
            [create_event(public: true), create_event(user_ids: [@reader.id])].each do |event|
                assert_equal event, EventService.new(@reader).show(event.id).result
                assert_raises(ActiveRecord::RecordNotFound) { EventService.new(@reader).show(event.id).update(title: "Changed") }
                assert_raises(ActiveRecord::RecordNotFound) { EventService.new(@reader).show(event.id).destroy }
                assert_raises(ActiveRecord::RecordNotFound) { EventService.new(@outsider).show(event.id) }
            end
        end

        test "omitted invitations are preserved and empty arrays remove them" do
            event = create_event(user_ids: ["", @reader.id, @reader.id])
            assert_equal 1, event.user_invitations.count
            assert update_event(event, title: "Changed").successful?
            assert_equal [@reader.id], event.user_ids
            respond_to_event(event, :accepted)
            assert update_event(event, user_ids: []).successful?
            assert_empty event.user_invitations.reload
            assert_equal 1, event.attendants.count
            assert_raises(ActiveRecord::RecordNotFound) { respond_to_event(event, :declined) }
            assert update_event(event, user_ids: [@reader.id]).successful?
            assert_equal "accepted", event.attendants.first.response
        end

        test "invalid invitation input retains the form and rolls back event changes" do
            event = create_event(user_ids: [@reader.id])
            service = update_event(event, title: "Submitted", user_ids: [@outsider.id])
            assert_not service.successful?
            assert_equal "Submitted", service.result.title
            assert_equal [@outsider.id.to_s], service.result.user_ids
            assert_equal "Planning", event.reload.title
            assert_equal [@reader.id], event.user_ids
            assert_no_difference("Event.count") do
                service = EventService.new(@author).create(title: "No date", user_ids: [@reader.id])
                assert_not service.successful?
                assert_equal [@reader.id.to_s], service.result.user_ids
            end
        end

        test "a failed invitation insertion rolls back creation" do
            failure = -> { errors.add(:base, "Insertion failed") }
            Event::UserInvitation.set_callback(:validate, :before, failure)
            assert_no_difference("Event.count") do
                service = EventService.new(@author).create(title: "Planning", start_at: 1.hour.from_now, end_at: 2.hours.from_now, user_ids: [@reader.id])
                assert_not service.successful?
                assert_not service.result.persisted?
                assert_equal [@reader.id.to_s], service.result.user_ids
                assert_includes service.errors_as_sentence, "Insertion failed"
            end
        ensure
            Event::UserInvitation.skip_callback(:validate, :before, failure)
        end

        test "responses are individual idempotent and never edit the event" do
            event = create_event(public: true)
            original = event.attributes
            first = respond_to_event(event, :accepted)
            assert_equal @reader, first.user
            travel 1.minute do
                repeated = respond_to_event(event, :accepted)
                assert_equal first.id, repeated.id
                assert_equal first.responded_at, repeated.responded_at
                assert_equal first.updated_at, repeated.updated_at
                changed = respond_to_event(event, :declined)
                assert_equal first.id, changed.id
                assert changed.response_declined?
                assert_operator changed.responded_at, :>, first.responded_at
            end
            assert_equal 1, event.attendants.count
            assert_equal original, event.reload.attributes
            assert_raises(ArgumentError) { EventResponseOperator.new(@reader, event.id).operate(response: :accepted, title: "Hack") }
        end

        test "failed response preserves its attempted value and rolls back the previous answer" do
            event = create_event(public: true)
            original = respond_to_event(event, :declined)
            failure = -> { errors.add(:base, "Response failed") if response_accepted? }
            Event::Attendant.set_callback(:validate, :before, failure)
            exception = assert_raises(ActiveRecord::RecordInvalid) { respond_to_event(event, :accepted) }
            assert exception.record.response_accepted?
            assert exception.record.errors[:base].present?
            assert original.reload.response_declined?
            assert_equal 1, event.attendants.count
        ensure
            Event::Attendant.skip_callback(:validate, :before, failure) if failure
        end

        test "rejects responses from ineligible users and to ended or cancelled events" do
            private_event = create_event
            public_event = create_event(public: true)
            assert_raises(ActiveRecord::RecordNotFound) { respond_to_event(private_event, :accepted) }
            assert_raises(ActiveRecord::RecordNotFound) { respond_to_event(public_event, :accepted, @outsider) }
            assert_raises(ActiveRecord::RecordInvalid) { respond_to_event(public_event, :accepted, @author) }
            [:pending, :unknown].each { |value| assert_raises(ActiveRecord::RecordInvalid) { respond_to_event(public_event, value) } }
            travel_to public_event.end_at, with_usec: true do
                assert_raises(ActiveRecord::RecordInvalid) { respond_to_event(public_event, :accepted) }
            end
            EventCancellationOperator.new(@author, public_event.id).operate
            assert_raises(ActiveRecord::RecordInvalid) { respond_to_event(public_event, :accepted) }
            assert_empty public_event.attendants
        end

        test "rescheduling resets only accepted responses atomically" do
            event = create_event(public: true)
            accepted = respond_to_event(event, :accepted)
            declined_user = create_user(@account, "declined")
            declined = respond_to_event(event, :declined, declined_user)
            assert update_event(event, title: "New title").successful?
            assert accepted.reload.response_accepted?
            assert update_event(event, start_at: 3.hours.from_now, end_at: 4.hours.from_now).successful?
            assert accepted.reload.response_pending?
            assert_nil accepted.responded_at
            assert declined.reload.response_declined?
            # A public participant can confirm again without a direct invitation.
            assert respond_to_event(event, :accepted).response_accepted?
        end

        test "failure resetting responses rolls back the schedule and invitations" do
            event = create_event(public: true)
            respond_to_event(event, :accepted)
            original_start = event.start_at
            failure = -> { errors.add(:base, "Reset failed") if response_pending? }
            Event::Attendant.set_callback(:validate, :before, failure)
            new_start = 3.hours.from_now
            service = update_event(event, start_at: new_start, end_at: 4.hours.from_now, user_ids: [@reader.id])
            assert_not service.successful?
            assert_equal new_start, service.result.start_at
            assert_equal [@reader.id.to_s], service.result.user_ids
            assert_equal original_start, event.reload.start_at
            assert_empty event.user_invitations
            assert event.attendants.first.response_accepted?
        ensure
            Event::Attendant.skip_callback(:validate, :before, failure)
        end

        test "cancellation and deletion preserve history and remove events from the feed" do
            event = create_event(public: true, user_ids: [@reader.id])
            response = respond_to_event(event, :accepted)
            assert_raises(ActiveRecord::RecordNotFound) { EventCancellationOperator.new(@reader, event.id).operate }
            cancelled = EventCancellationOperator.new(@author, event.id).operate
            repeated = EventCancellationOperator.new(@author, event.id).operate
            assert_equal cancelled.updated_at, repeated.updated_at
            assert_equal response.attributes, response.reload.attributes
            assert_not EventService.new(@reader).calendar_entries.any? { |entry| entry[:id] == event.id }
            assert_not update_event(event, title: "Reopen", status: "scheduled").successful?
            EventService.new(@author).show(event.id).destroy
            assert Event.with_deleted.find(event.id).deleted_at.present?
            assert_equal 1, Event::UserInvitation.where(event_id: event.id).count
            assert_equal 1, Event::Attendant.where(event_id: event.id).count
            assert_raises(ActiveRecord::RecordNotFound) { respond_to_event(event, :declined) }
        end

        test "public discovery does not imply acceptance and privacy changes apply immediately" do
            event = create_event(public: true)
            assert_no_difference("Event::Attendant.count") { EventService.new(@reader).show(event.id) }
            assert_empty EventService.new(@reader).calendar_entries
            respond_to_event(event, :accepted)
            assert_equal [event.id], EventService.new(@reader).calendar_entries.pluck(:id)
            assert update_event(event, public: false).successful?
            assert_empty EventService.new(@reader).calendar_entries
            assert_raises(ActiveRecord::RecordNotFound) { EventService.new(@reader).show(event.id) }
        end

        test "role membership remains dynamic and multiple matches do not duplicate events" do
            skip "LesliShield is optional" unless defined?(LesliShield)
            role = @account.roles.first!
            event = create_event(user_ids: [@reader.id], role_ids: [role.id])
            membership = LesliShield::User::Role.create!(user: @reader, role: role)
            assert_equal 1, EventService.new(@reader).index.result.where(id: event.id).count
            respond_to_event(event, :accepted)
            assert update_event(event, user_ids: []).successful?
            assert_equal event, EventService.new(@reader).show(event.id).result
            membership.destroy!
            assert_raises(ActiveRecord::RecordNotFound) { EventService.new(@reader).show(event.id) }
            assert event.attendants.first.response_accepted?
        end

        test "foreign roles fail and role invitations require Shield" do
            attributes = { role_ids: [@other_account.roles.first!.id] }
            service = EventService.new(@author).create(title: "Invalid roles", start_at: 1.hour.from_now, end_at: 2.hours.from_now, **attributes)
            assert_not service.successful?
            unless defined?(LesliShield)
                service = EventService.new(@author).create(title: "No Shield", start_at: 1.hour.from_now, end_at: 2.hours.from_now, role_ids: [@account.roles.first!.id])
                assert_not service.successful?
            end
        end
    end
end
