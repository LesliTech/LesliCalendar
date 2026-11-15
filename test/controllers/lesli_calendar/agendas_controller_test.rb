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

        test "my events includes history and filters by date overlap" do
            past = EventService.new(@user).create(attributes.merge(title: "Past event",
                start_at: Time.utc(2025, 1, 1, 23), end_at: Time.utc(2025, 1, 2, 1))).result
            EventService.new(@user).create(attributes.merge(title: "Future event"))
            get :show, params: { view: "mine" }, format: :json
            assert_includes response.body, "Past event"
            assert_includes response.body, "Future event"
            get :show, params: { view: "mine", from: "2025-01-02", to: "2025-01-02" }, format: :html
            assert_response :success
            assert_select "a[data-turbo-frame=calendar-event-detail][href=?]", event_path(past)
            assert_select "input[name=from][value='2025-01-02']"
            refute_includes response.body, "Future event"
        end

        test "invalid views and malformed dates return bad request" do
            get :show, params: { view: "destroy" }
            assert_response :bad_request
            get :show, params: { view: "mine", from: "invalid" }
            assert_response :bad_request
        end
    end
end
