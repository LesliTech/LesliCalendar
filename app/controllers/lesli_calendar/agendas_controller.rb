module LesliCalendar
    class AgendasController < ApplicationController
        def show
            request.format = :html if request.format.turbo_stream?
            @agenda = EventService.new(current_user).agenda
            respond_with_lesli(json: @agenda)
        end
    end
end
