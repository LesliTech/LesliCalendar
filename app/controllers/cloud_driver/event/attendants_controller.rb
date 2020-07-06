require_dependency "cloud_driver/application_controller"

module CloudDriver
=begin

Lesli

Copyright (c) 2020, Lesli Technologies, S. A.

All the information provided by this website is protected by laws of Guatemala related 
to industrial property, intellectual property, copyright and relative international laws. 
Lesli Technologies, S. A. is the exclusive owner of all intellectual or industrial property
rights of the code, texts, trade mark, design, pictures and any other information.
Without the written permission of Lesli Technologies, S. A., any replication, modification,
transmission, publication is strictly forbidden.
For more information read the license file including with this software.

LesliCloud - Your Smart Business Assistant

Powered by https://www.lesli.tech
Building a better future, one line of code at a time.

@author   Carlos Hermosilla
@license  Propietary - all rights reserved.
@version  0.1.0-alpha
@description Controller for event attendants

=end
    class Event::AttendantsController < ApplicationController
        before_action :set_event, only: [:create, :destroy]
        before_action :check_has_authorization, only: [:create, :destroy]

=begin
@return [HTML|JSON] HTML view for listing all attendants of an event or a Json that contains a list of 
    all attendants associated to certain event 
@description Retrieves and returns all event attendants associated to a *ClouDriver::Account* and a
    *CloudDriver::Event*. The account is obtained directly from *current_user*. The HTTP request has to specify
    wheter the HTML or the JSON text should be rendered
@example
    # Executing this controller's action from javascript's frontend
    let event_id: 1;
    this.http.get(`127.0.0.1/driver/events/${event_id}/attendants`);
=end
        def index
            respond_to do |format|
                format.html {}
                format.json do
                    set_event
                    return responseWithNotFound unless @event

                    responseWithSuccessful(@event.attendant_list) 
                end
            end
        end

=begin
@controller_action_param :users_id [Integer] The id of the user that is going to be added as an attendant
@return [Json] Json that contains wheter the creation of the attendant was successful or not. 
    If it is not successful, it returns an error message
@description Creates a new attendant associated to the *current_user*'s *account* and to the
    event specified by the *event_id* param.
@example
    # Executing this controller's action from javascript's frontend
    let data = {
        event_attendant: {
            users_id: 3
        }
    };
    let event_id = 3;
    this.http.post(`127.0.0.1/driver/events/${this.event_id}/attendants`, data);
=end
        def create
            return responseWithNotFound unless @event

            attendant = Event::Attendant.new(event_attendant_params)
            attendant.event = @event

            if attendant.save
                responseWithSuccessful(attendant)

                Event.log_activity_create_attendant(current_user, @event, attendant)
                Event.send_notification_create_attendant(attendant)
                Event.send_email_create_attendant(attendant)
            else
                responseWithError(attendant.errors.full_messages.to_sentence)
            end
        end

=begin
@return [Json] Json that contains wheter the event attendant was successfully deleted or not. 
    If it it not successful, it returns an error message
@description Deletes an existing *event* *attendant* associated to the *current_user*'s *account*.
@example
    # Executing this controller's action from javascript's frontend
    let event_id = 4;
    let attendant_id = 5;
    this.http.delete(`127.0.0.1/driver/events/${event_id}/attendants/${attendant_id}`);
=end
        def destroy
            return responseWithNotFound unless @event
            attendant = @event.attendants.find_by(id: params[:id])
            return responseWithNotFound unless attendant

            if attendant.destroy
                responseWithSuccessful
            else
                responseWithError(attendant.errors.full_messages.to_sentence)
            end
        end

        private

        def is_creator_or_assigned?()
            is_assigned_user = false
            is_organizer = false
            is_assigned_user = current_user == @event.user if @event.user
            is_organizer = current_user.id == @event.organizer_id
            return is_assigned_user || is_organizer
        end

        def check_has_authorization
            return true if current_user.is_role?("owner", "admin")
            return true if is_creator_or_assigned?()
            return responseWithUnauthorized
        end
        
=begin
@return [void]
@description Sets the variable @event. The variable contains the *event*
    to be handled by the controller action that called this method
@example
    #suppose params[:event_id] = 1
    puts @event # will display nil
    set_event
    puts @event # will display an instance of CloudHouse:Event
=end
        def set_event
            @event = Event.find_by(
                id: params[:event_id],
                cloud_driver_accounts_id: current_user.account.id
            )
        end

=begin
@return [Parameters] Allowed parameters for the event
@description Sanitizes the parameters received from an HTTP call to only allow the specified ones.
    Allowed params are :users_id
@example
    # supose params contains {
    #    "event_attendant": {
    #        "id": 5,
    #        "users_id": 6
    #    }
    #}
    filtered_params = event_attendant_params
    puts filtered_params
    # will remove all extra fields and only print {
    #    "users_id": 6
    #}
=end
        def event_attendant_params
            params.fetch(:event_attendant, {}).permit(
                :users_id
            )
        end
    end
end
