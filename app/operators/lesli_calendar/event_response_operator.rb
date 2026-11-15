module LesliCalendar
    class EventResponseOperator
        def initialize(current_user, event_id)
            @current_user = current_user
            @event_id = event_id
        end

        # Returns the participation record. The event lock serializes responses,
        # rescheduling, invitation replacement, cancellation, and deletion.
        def operate(response:)
            event = Event.visible_to(@current_user).find(@event_id)
            event.with_lock do
                # Recheck visibility after waiting for a concurrent invitation edit.
                Event.visible_to(@current_user).find(event.id)
                reject!(event, :cancelled) if event.cancelled?
                reject!(event, :ended) if event.end_at <= Time.current
                reject!(event, :organizer_response) if event.user_id == @current_user.id
                reject!(event, :invalid_response) unless %w[accepted declined].include?(response.to_s)

                attendant = event.attendants.find_or_initialize_by(user: @current_user)
                return attendant if attendant.persisted? && attendant.response == response.to_s

                attendant.update!(response: response, responded_at: Time.current)
                attendant
            end
        end

        private

        def reject!(event, reason)
            event.errors.add(:base, I18n.t("lesli_calendar.events.errors.#{reason}"))
            raise ActiveRecord::RecordInvalid.new(event)
        end
    end
end
