module LesliCalendar
    class ApplicationController < Lesli::ApplicationLesliController
        around_action :use_calendar_timezone

        private

        def use_calendar_timezone(&action)
            # The browser supplies an IANA zone; Rails keeps database timestamps in UTC.
            zone = Time.find_zone(cookies[:lesli_calendar_time_zone]) ||
                Time.find_zone!(Lesli.config.datetime&.dig(:time_zone)) || Time.zone
            Time.use_zone(zone, &action)
        end
    end
end
