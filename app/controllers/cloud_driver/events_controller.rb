=begin

Copyright (c) 2020, all rights reserved.

All the information provided by this platform is protected by international laws related  to 
industrial property, intellectual property, copyright and relative international laws. 
All intellectual or industrial property rights of the code, texts, trade mark, design, 
pictures and any other information belongs to the owner of this platform.

Without the written permission of the owner, any replication, modification,
transmission, publication is strictly forbidden.

For more information read the license file including with this software.

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 


Registro de participantes
Confirmacion de participantes
monthly budget of event
budget of the event
location


privacy 
    public      -> account calendar privacy as public
    private     -> user calendar privacy as private
    internal    -> account calendar privacy as private

budget 


=end
require_dependency "cloud_driver/application_controller"
require 'google/api_client/client_secrets'
require 'google/apis/calendar_v3'
module CloudDriver
    class EventsController < ApplicationLesliController
        before_action :set_event, only: [:update, :destroy, :show]
        before_action :parse_query_params, only: :index

        # GET /events
        def index
            respond_to do |format|
                format.html { }
                format.json do
                    respond_with_successful(Event.index(current_user, @query))
                end
            end
        end

        # GET /events/1
        def show
            respond_to do |format|
                format.html { }
                format.json do 
                    return responseWithNotFound unless @event
                    respond_with_successful(@event.show(current_user))
                end
                format.ics do
                    return responseWithNotFound unless @event
                    render plain: @event.download
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
            event_create_response = CloudDriver::EventServices.create(current_user, event_params)

            return respond_with_error(event_create_response.error) if !event_create_response.successful?

            event = event_create_response.payload

            user_auth_provider = Courier::Lesli::Users::AuthProviders.get_user_provider(current_user.id, 'Google')

            if user_auth_provider
                CloudDriver::EventServices.create_external_event(current_user, event_params)
            end

            if event_create_response.successful?
                respond_with_successful(event.show(current_user))
            else
                respond_with_error(event.errors.full_messages.to_sentence)
            end
        end

        # PATCH/PUT /events/1
        def update
            return responseWithNotFound unless @event
            return responseWithUnauthorized unless @event.is_editable_by?(current_user)

            if @event.update(event_params)
                respond_with_successful(@event)
            else
                respond_with_error(@event.errors.full_messages.to_sentence)
            end
        end

        # DELETE /events/1
        def destroy
            return responseWithNotFound unless @event
            return responseWithUnauthorized unless @event.is_editable_by?(current_user)

            if @event.destroy
                return respond_with_successful
            else
                return respond_with_error(@event.errors.full_messages.to_sentence)
            end
        end

        def events_by_model
            events = Courier::Driver::Event.by_model(params[:model_type], params[:model_id], current_user, @query)
            respond_with_successful(events)
        end

        def options
            # parse query string here to include or exclude options
            respond_with_successful({
                event_types: current_user.account.driver.event_types.map {|event_type| {value: event_type.id, text: event_type.name}}
            })
        end

        protected

        # Use callbacks to share common setup or constraints between actions.
        def set_event
            @event = current_user.account.driver.events.find(params[:id])
        end

        # Only allow a trusted parameter "white list" through.
        def event_params
            params.fetch(:event, {}).permit(
                :model_id,
                :model_type,
                :user_main_id,
                :cloud_driver_catalog_event_types_id,
                :source,
                :external_uid,
                detail_attributes: [
                    :title, 
                    :description, 
                    :event_date,
                    :time_start, 
                    :time_end, 
                    :location, 
                    :budget,
                    :real_cost,
                    :signed_up_count,
                    :showed_up_count,
                    :url, 
                    :public
                ]
            )
        end

        def parse_query_params
            @query[:filters][:start_date] = @query[:filters][:start_date].to_datetime if @query[:filters][:start_date]
            @query[:filters][:end_date] = @query[:filters][:end_date].to_datetime if @query[:filters][:end_date]
        end
    end
end
