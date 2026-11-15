module LesliCalendar
    class CalendarsController < ApplicationController
        def show
            request.format = :html if request.format.turbo_stream?
            @calendar = CalendarService.new(current_user).find_default.result
            respond_with_lesli(json: @calendar.as_json)
        end
    end
end
