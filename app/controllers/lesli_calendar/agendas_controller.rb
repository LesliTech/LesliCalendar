module LesliCalendar
    class AgendasController < ApplicationController
        def show
            @agenda = EventService.new(current_user).agenda
        end
    end
end
