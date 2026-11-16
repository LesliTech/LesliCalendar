require_relative "events_controller_test"

module LesliCalendar
    class CalendarTimezoneTest < ActionController::TestCase
        include CalendarControllerSetup
        tests CalendarsController
        setup { prepare_calendar_controller }

        test "FullCalendar receives and displays the profile zone" do
            @user.update!(time_zone: "Europe/Berlin")
            get :show
            assert_response :success
            assert_select "lesli-calendar[data-time-zone='Europe/Berlin']"
            assert_select ".lesli-calendar-calendar p", text: "Europe/Berlin"
        end

        test "FullCalendar uses the application zone without a profile preference" do
            previous_datetime = Lesli.config.datetime
            Lesli.config.datetime = { time_zone: "America/Guatemala" }
            get :show
            assert_response :success
            assert_select "lesli-calendar[data-time-zone='America/Guatemala']"
        ensure
            Lesli.config.datetime = previous_datetime
        end
    end
end
