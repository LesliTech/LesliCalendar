module LesliCalendar
    class ApplicationController < Lesli::ApplicationLesliController
        around_action :use_calendar_timezone

        private

        def use_calendar_timezone(&action)
            Time.use_zone("UTC", &action)
        end
    end
end
