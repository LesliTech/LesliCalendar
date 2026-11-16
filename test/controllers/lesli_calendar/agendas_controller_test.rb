require_relative "events_controller_test"

module LesliCalendar
    class AgendasControllerTest < ActionController::TestCase
        include CalendarControllerSetup
        tests AgendasController
        setup { prepare_calendar_controller }

        test "agenda has four views and a shared event panel" do
            %w[upcoming mine pending available].each do |view|
                get :show, params: { view: view }
                assert_response :success
                assert_select "nav a[aria-current=page][href=?]", agenda_path(view: view)
                assert_select "turbo-frame#calendar-event-detail"
                assert_select "input[name=from]", count: view == "mine" ? 1 : 0
            end
        end

        test "my events includes history and filters by local date overlap" do
            @user.update!(time_zone: "America/Guatemala")
            # 05:00–07:00 UTC spans 23:00–01:00 locally, across January 1 and 2.
            past = EventService.new(@user).create(attributes.merge(title: "Past event",
                start_at: Time.utc(2025, 1, 2, 5), end_at: Time.utc(2025, 1, 2, 7))).result
            previous_day = EventService.new(@user).create(attributes.merge(title: "Previous local day",
                start_at: Time.utc(2025, 1, 2, 1), end_at: Time.utc(2025, 1, 2, 2))).result
            EventService.new(@user).create(attributes.merge(title: "Future event"))
            get :show, params: { view: "mine" }, format: :json
            assert_includes response.body, "Past event"
            assert_includes response.body, "Future event"
            get :show, params: { view: "mine", from: "2025-01-02", to: "2025-01-02" }, format: :html
            assert_response :success
            assert_select "a[data-turbo-frame=calendar-event-detail][href=?]", event_path(past)
            assert_select "a[data-turbo-frame=calendar-event-detail][href=?]", event_path(previous_day), count: 0
            assert_select "input[name=from][value='2025-01-02']"
            refute_includes response.body, "Future event"
        end

        test "agenda frame preserves filters and reflects edits and cancellation" do
            @user.update!(time_zone: "America/Guatemala")
            event = EventService.new(@user).create(attributes.merge(
                start_at: Time.utc(2027, 1, 15, 15), end_at: Time.utc(2027, 1, 15, 16))).result
            filters = { view: "mine", from: "2027-01-15", to: "2027-01-15" }
            @request.headers["Turbo-Frame"] = "calendar-agenda-list"
            get :show, params: filters
            assert_response :success
            assert_select "turbo-frame#calendar-agenda-list[data-refresh-url=?]", agenda_path(**filters)
            assert_select "turbo-frame#calendar-agenda-list a[href=?]", event_path(event)

            service = EventService.new(@user)
            service.show(event.id)
            service.update(title: "Edited from panel")
            assert service.successful?
            get :show, params: filters
            assert_select "turbo-frame#calendar-agenda-list a", text: "Edited from panel"

            EventCancellationOperator.new(@user, event.id).operate
            get :show, params: filters
            assert_select "turbo-frame#calendar-agenda-list a[href=?]", event_path(event), count: 0
            assert_select "input[name=from][value='2027-01-15']"
        end

        test "accepted invitations disappear when the pending frame reloads" do
            organizer = @account.users.new(email: "agenda-organizer@example.test")
            if organizer.respond_to?(:password=)
                organizer.password = "Password123!"
                organizer.confirmed_at = Time.current
            end
            organizer.save!
            event = EventService.new(organizer).create(attributes.merge(user_ids: [@user.id])).result
            @request.headers["Turbo-Frame"] = "calendar-agenda-list"
            get :show, params: { view: "pending" }
            assert_select "turbo-frame#calendar-agenda-list a[href=?]", event_path(event)

            EventResponseOperator.new(@user, event.id).operate(response: :accepted)
            get :show, params: { view: "pending" }
            assert_response :success
            assert_select "turbo-frame#calendar-agenda-list a[href=?]", event_path(event), count: 0
            assert_select "turbo-frame#calendar-agenda-list[data-refresh-url=?]", agenda_path(view: "pending")
        end

        test "invalid views and malformed dates return bad request" do
            get :show, params: { view: "destroy" }
            assert_response :bad_request
            get :show, params: { view: "mine", from: "invalid" }
            assert_response :bad_request
        end
    end
end
