module LesliCalendar
    class Event::AttendantsController < ApplicationController
        rescue_from ActiveRecord::RecordNotFound do
            respond_with_not_found
        end

        def update
            attendant = EventResponseOperator.new(current_user, params[:event_id])
                .operate(response: params.require(:attendant).fetch(:response, nil))
            success(t("lesli_calendar.events.response_saved"))
            respond_with_lesli(json: attendant.as_json, redirect: event_path(params[:event_id]))
        rescue ActiveRecord::RecordInvalid => exception
            @event = EventService.new(current_user).show(params[:event_id]).result
            @event.errors.add(:base, exception.record.errors.full_messages.to_sentence)
            @participation = @event.attendants.find_by(user_id: current_user.id)
            respond_with_lesli(html: "lesli_calendar/events/show", json: { errors: exception.record.errors.to_hash },
                turbo: turbo_stream.replace("event-detail", partial: "lesli_calendar/events/event"),
                status: :unprocessable_content)
        end
    end
end
