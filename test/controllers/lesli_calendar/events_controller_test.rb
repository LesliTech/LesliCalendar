require "test_helper"

module LesliCalendar
    module CalendarControllerSetup
        def prepare_calendar_controller
            @routes = Engine.routes
            @account = Lesli::Account.create!(name: "Calendar UI", email: "calendar-ui@example.test", status: :active)
            @user = @account.users.new(email: "calendar-ui@example.test")
            if @user.respond_to?(:password=)
                @user.password = "Password123!"
                @user.confirmed_at = Time.current
            end
            @user.save!
            user = @user
            @controller.define_singleton_method(:current_user) { user }
            @controller.class.helper_method :current_user
            @controller.define_singleton_method(:authenticate_request) { true }
            @controller.define_singleton_method(:authorize_request) { true }
            @controller.define_singleton_method(:log_requests) { true }
            @controller.define_singleton_method(:log) { |*| true }
            @controller.define_singleton_method(:_layout) { |*| false }
        end

        def attributes
            { title: "Review", start_at: 1.hour.from_now, end_at: 2.hours.from_now, public: true }
        end
    end

    class EventsControllerTest < ActionController::TestCase
        include CalendarControllerSetup
        tests EventsController
        setup { prepare_calendar_controller }

        test "HTML and Turbo forms retain fields and invitations on error" do
            get :new
            assert_response :success
            assert_select "input[name='event[title]']"
            assert_select "select[name='event[user_ids][]'][multiple]"
            assert_select "select[name='event[role_ids][]']", count: defined?(LesliShield) ? 1 : 0
            [:html, :turbo_stream].each do |format|
                post :create, params: { event: attributes.merge(title: "", description: "Keep this", user_ids: [@user.id]) }, format: format
                assert_response :unprocessable_content
                assert_select "textarea[name='event[description]']", text: "Keep this"
                assert_select "select[name='event[user_ids][]'] option[selected][value=?]", @user.id.to_s
                assert_select "[role=alert]"
            end
        end

        test "create update cancel and delete return coherent JSON and redirects" do
            post :create, params: { event: attributes }, format: :json
            assert_response :created
            event = Event.find(response.parsed_body.fetch("id"))
            patch :update, params: { id: event.id, event: { title: "Updated", account_id: 999 } }, format: :turbo_stream
            assert_response :see_other
            assert_redirected_to event_path(event)
            get :show, params: { id: event.id }, format: :turbo_stream
            assert_response :success
            assert_equal "text/html", response.media_type
            assert_includes response.body, "Updated"
            patch :cancel, params: { id: event.id }, format: :json
            assert_response :success
            assert event.reload.cancelled?
            delete :destroy, params: { id: event.id }, format: :turbo_stream
            assert_redirected_to agenda_path(view: "mine")
            assert Event.with_deleted.find(event.id).deleted_at
        end

        test "visible month and discovery pages are independent" do
            event = EventService.new(@user).create(attributes.merge(start_at: Time.utc(2027, 2, 10), end_at: Time.utc(2027, 2, 10, 1))).result
            get :index, params: { month: "2027-02" }, format: :json
            assert_response :success
            assert_includes response.parsed_body.pluck("id"), "lesli_calendar:event:#{event.id}"
            get :index, params: { month: "not-a-month" }, format: :json
            assert_response :bad_request
            { index: "mine", pending: "pending", available: "available" }.each do |action, view|
                get action, format: :html
                assert_redirected_to agenda_path(view: view)
            end
        end

        test "panel detail and editing stay inside the frame" do
            event = EventService.new(@user).create(attributes.merge(url: "/support/tickets/42")).result
            @request.headers["Turbo-Frame"] = "calendar-event-detail"
            get :show, params: { id: event.id }
            assert_response :success
            assert_select "turbo-frame#calendar-event-detail" do
                assert_select "a[href=?][data-turbo-frame=calendar-event-detail]", edit_event_path(event)
                assert_select "a[href='/support/tickets/42'][data-turbo-frame=_top]"
                assert_select "button[data-turbo-frame=calendar-event-detail]"
            end
            get :edit, params: { id: event.id }
            assert_response :success
            assert_select "turbo-frame#calendar-event-detail form[data-turbo-frame=calendar-event-detail]"
            patch :update, params: { id: event.id, event: { title: "" } }, format: :turbo_stream
            assert_response :unprocessable_content
            assert_select "turbo-stream[target=event-form] form[data-turbo-frame=calendar-event-detail]"
            patch :update, params: { id: event.id, event: { title: "Panel update" } }, format: :turbo_stream
            assert_redirected_to event_path(event)
            get :show, params: { id: event.id }, format: :turbo_stream
            assert_select "turbo-frame#calendar-event-detail", text: /Panel update/
            patch :cancel, params: { id: event.id }, format: :turbo_stream
            assert_redirected_to event_path(event)
            get :show, params: { id: event.id }, format: :turbo_stream
            assert_select "turbo-frame#calendar-event-detail"
            assert event.reload.cancelled?
        end

        test "another organizer cannot edit a visible public event" do
            other = @account.users.new(email: "other-organizer@example.test")
            other.password = "Password123!" if other.respond_to?(:password=)
            other.confirmed_at = Time.current if other.respond_to?(:confirmed_at=)
            other.save!
            event = EventService.new(other).create(attributes).result
            @request.headers["Turbo-Frame"] = "calendar-event-detail"
            get :show, params: { id: event.id }
            assert_response :success
            assert_select "turbo-frame#calendar-event-detail button[data-turbo-frame=calendar-event-detail]", count: 2
            get :edit, params: { id: event.id }, format: :json
            assert_response :not_found
            patch :update, params: { id: event.id, event: { title: "Forbidden" } }, format: :json
            assert_response :not_found
            patch :cancel, params: { id: event.id }, format: :json
            assert_response :not_found
        end
    end

    class EventAttendantsControllerTest < ActionController::TestCase
        include CalendarControllerSetup
        tests Event::AttendantsController
        setup do
            prepare_calendar_controller
            @organizer = @account.users.new(email: "inviter@example.test")
            @organizer.password = "Password123!" if @organizer.respond_to?(:password=)
            @organizer.confirmed_at = Time.current if @organizer.respond_to?(:confirmed_at=)
            @organizer.save!
            @event = EventService.new(@organizer).create(attributes.merge(user_ids: [@user.id])).result
        end

        test "response uses authenticated user and ignores event mutations" do
            patch :update, params: { event_id: @event.id, attendant: { response: "accepted", user_id: @organizer.id, title: "Changed" } }, format: :json
            assert_response :success
            assert_equal @user.id, response.parsed_body["user_id"]
            assert_equal "Review", @event.reload.title
            patch :update, params: { event_id: @event.id, attendant: { response: "declined" } }, format: :turbo_stream
            assert_redirected_to event_path(@event)
            assert_equal 1, @event.attendants.count
            assert_equal "declined", @event.attendants.first.response
        end

        test "invalid response leaves the event and participation unchanged" do
            patch :update, params: { event_id: @event.id, attendant: { response: "invalid" } }, format: :turbo_stream
            assert_response :unprocessable_content
            assert_select "turbo-stream[target=event-detail]"
            assert_empty @event.attendants
        end
    end
end
