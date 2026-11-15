module LesliCalendar
    class AgendasController < ApplicationController
        def show
            @agenda_page = [params[:page].to_i, 1].max
            service = EventService.new(current_user)
            @agenda = service.agenda(page: @agenda_page)
            @agenda_next_page = service.agenda_next_page
        end
    end
end
