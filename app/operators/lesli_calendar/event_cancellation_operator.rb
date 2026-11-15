module LesliCalendar
    class EventCancellationOperator
        def initialize(current_user, event_id)
            @current_user = current_user
            @event_id = event_id
        end

        # Cancellation retains invitations and responses, and repeated calls are harmless.
        def operate
            event = @current_user.account.calendar.events.where(user_id: @current_user.id).find(@event_id)
            event.with_lock do
                @current_user.account.calendar.events.where(user_id: @current_user.id).find(event.id)
                event.update!(status: :cancelled) unless event.cancelled?
            end
            event
        end
    end
end
