module LesliCalendar
    class EventsController < ApplicationController
        prepend_before_action :use_html_for_page_navigation
        before_action :load_service
        before_action :load_event, only: [:show, :edit, :update, :destroy, :cancel]
        before_action :load_invitation_options, only: [:new, :edit, :create, :update]
        rescue_from ActiveRecord::RecordNotFound do
            respond_with_not_found
        end

        def index
            if request.format.json?
                return respond_with_lesli(json: @service.calendar_entries)
            end
            @events = @service.my_calendar.result
            @list_title = t("lesli_calendar.events.mine")
            respond_with_lesli
        rescue ArgumentError
            head :bad_request
        end

        def pending
            @events = @service.pending_invitations.result
            @list_title = t("lesli_calendar.events.pending")
            respond_with_lesli(html: :index, json: @events.as_json)
        end

        def available
            @events = @service.available_events.result
            @list_title = t("lesli_calendar.events.available")
            respond_with_lesli(html: :index, json: @events.as_json)
        end

        def show
            @participation = @event.attendants.find_by(user_id: current_user.id)
            respond_with_lesli(json: event_json)
        end

        def new
            @event = Event.new(start_at: 1.hour.from_now.change(min: 0), end_at: 2.hours.from_now.change(min: 0))
            respond_with_lesli(json: @event.as_json)
        end

        def edit
            raise ActiveRecord::RecordNotFound unless @event.user_id == current_user.id
            respond_with_lesli(json: event_json)
        end

        def create
            @service.create(event_params)
            save_response(:new, :created, :created)
        end

        def update
            @service.update(event_params)
            save_response(:edit, :updated, :ok)
        end

        def destroy
            @service.destroy
            success(t("lesli_calendar.events.deleted"))
            respond_with_lesli(json: { id: @event.id }, redirect: events_path)
        end

        def cancel
            @event = EventCancellationOperator.new(current_user, @event.id).operate
            success(t("lesli_calendar.events.cancelled_notice"))
            respond_with_lesli(json: event_json, redirect: event_path(@event))
        rescue ActiveRecord::RecordInvalid => exception
            @event = exception.record
            respond_with_lesli(html: :show, json: { errors: @event.errors.to_hash },
                turbo: stream_notification_danger(@event.errors.full_messages.to_sentence), status: :unprocessable_content)
        end

        private

        # Redirected Turbo form requests must render complete HTML pages on their next GET.
        def use_html_for_page_navigation
            request.format = :html if request.get? && request.format.turbo_stream?
        end

        def load_service
            @service = EventService.new(current_user, month: params[:month])
        end

        def load_event
            @event = @service.show(params[:id]).result
        end

        def load_invitation_options
            @invitation_users = current_user.account.users.order(:email).pluck(:email, :id)
            @invitation_roles = current_user.account.roles.order(:name).pluck(:name, :id) if defined?(LesliShield)
        end

        def event_params
            params.require(:event).permit(*EventService::EDITABLE_ATTRIBUTES, user_ids: [], role_ids: []).to_h
        end

        def event_json
            @event.as_json.merge(user_ids: @event.user_ids, role_ids: @event.role_ids,
                response: @participation&.response)
        end

        def save_response(template, message, status)
            @event = @service.result
            unless @service.successful?
                return respond_with_lesli(html: template, json: { errors: @event.errors.to_hash },
                    turbo: turbo_stream.replace("event-form", partial: "lesli_calendar/events/form"),
                    status: :unprocessable_content)
            end
            success(t("lesli_calendar.events.#{message}"))
            respond_with_lesli(json: event_json, status: status, redirect: event_path(@event))
        end
    end
end
