module LesliCalendar
    class AgendasController < ApplicationController
        def show
            request.format = :html if request.format.turbo_stream?
            @agenda_view = params[:view].presence || "upcoming"
            return head :bad_request unless %w[upcoming mine pending available].include?(@agenda_view)

            @agenda = EventService.new(current_user).agenda(
                view: @agenda_view, from: params[:from], to: params[:to]
            )
            respond_with_lesli(json: @agenda)
        rescue Date::Error
            head :bad_request
        end
    end
end
