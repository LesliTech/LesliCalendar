=begin
Copyright (c) 2022, all rights reserved.

All the information provided by this platform is protected by international laws related  to 
industrial property, intellectual property, copyright and relative international laws. 
All intellectual or industrial property rights of the code, texts, trade mark, design, 
pictures and any other information belongs to the owner of this platform.

Without the written permission of the owner, any replication, modification,
transmission, publication is strictly forbidden.

For more information read the license file including with this software.

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 

=end
require_dependency "cloud_driver/application_controller"

module CloudDriver
    class Event::GuestsController < ApplicationController
        before_action :set_event, only: [:create, :destroy, :update]

        # GET /event/guests
        def index
            respond_to do |format|
                format.html {}
                format.json do
                    set_event
                    return responseWithNotFound unless @event
                    responseWithSuccessful(@event.guest_list) 
                end
            end
        end

        # POST /event/guests
        def create
            return respond_with_not_found unless @event
            return respond_with_unauthorized unless @event.is_editable_by?(current_user)

            guest = @event.guests.new(event_guest_params)

            if guest.save
                responseWithSuccessful(guest)

                #Event.log_activity_create_guest(current_user, @event, guest)
                #Event.send_notification_create_guest(attendant)
                #EventMailer.with({user: guest.email, event: @event}).guest.deliver_later
            else
                responseWithError(guest.errors.full_messages.to_sentence)
            end
        end

        # PATCH/PUT /event/guests/1
        def update
            guest = @event.guests.find_by(id: params["id"])
            guest.confirm_attendance
            respond_with_successful(guest)
        end

        # DELETE /event/guests/1
        def destroy
            return respond_with_not_found unless @event
            return respond_with_unauthorized unless @event.is_editable_by?(current_user)

            guest = @event.guests.find_by(id: params[:id])
            return responseWithNotFound unless guest

            if guest.destroy
                responseWithSuccessful
            else
                responseWithError(guest.errors.full_messages.to_sentence)
            end
        end

        private

        # Use callbacks to share common setup or constraints between actions.
        def set_event
            @event = Event.find_by(
                id: params[:event_id],
                cloud_driver_accounts_id: current_user.account.id
            )
        end

        # Only allow a list of trusted parameters through.
        def event_guest_params
            params.fetch(:event_guest, {}).permit(:id, :name, :email, :confirmed_at)
        end
    end
end
