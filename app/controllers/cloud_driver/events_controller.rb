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

@license  Propietary - all rights reserved.
@version  0.1.0-alpha

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 

=end
require_dependency "cloud_driver/application_controller"

module CloudDriver
    class EventsController < ApplicationController
        before_action :set_event, only: [:update, :destroy, :show]

        # GET /events
        def index
            responseWithSuccessful()
        end

        # GET /events/1
        def show
            respond_to do |format|
                format.html { }
                format.json do 
                    return responseWithNotFound unless @event
                    responseWithSuccessful(@event.show)
                end
                format.ics do
                    return responseWithNotFound unless @event
                    responseWithSuccessful(@event.download)
                end
            end
        end

        # GET /events/new
        def new
            @event = Event.new
        end

        # GET /events/1/edit
        def edit
        end

        # POST /events
        def create
            # event = current_user.account.driver.calendars.default().events.create(event_params)
            event = Event.new(event_params)            
            event.account = current_user.account
            event.user = current_user # event creator

            unless event_params[:organizer_id]
                event.organizer = current_user                
            end
            event.calendar = current_user.account.driver.calendars.default
            
            if event.save
                Event.log_activity_create(current_user, event)
                event.attendants.create(users_id: event.organizer.id)
                responseWithSuccessful(event.show)
            else
                responseWithError('Error creationg event', event.errors.full_messages)
            end
        end

        # PATCH/PUT /events/1
        def update
            #@event.detail.title = event_params[:]
            if @event.update(event_params)
                responseWithSuccessful(@event)
            else
                responseWithError(@event.errors)
            end
        end

        # DELETE /events/1
        def destroy
            return responseWithNotFound unless @event
            if @event.destroy
                return responseWithSuccessful
            else
                return responseWithError("Error deleting event", @event.errors.full_messages)
            end
        end

        def events_by_model
            events = Courier::Driver::Event.by_model(params[:model_type], params[:model_id], current_user, @query)
            responseWithSuccessful(events)
        end

        def options
            # parse query string here to include or exclude options
            responseWithSuccessful({
                event_types: Event.event_types.map {|k, _| {value: k, text: I18n.t("driver.events.enum_event_type_#{k}")}}
            })
        end

        private

        # Use callbacks to share common setup or constraints between actions.
        def set_event
            @event = current_user.account.driver.events.find(params[:id])
        end

        # Only allow a trusted parameter "white list" through.
        def event_params
            params.require(:event).permit(
                :model_id,
                :model_type,
                :organizer_id,
                detail_attributes: [
                    :title, 
                    :description, 
                    :time_start, 
                    :time_end, 
                    :location, 
                    :url, 
                    :event_type,
                    :public
                ]
            )
        end
    end
end
