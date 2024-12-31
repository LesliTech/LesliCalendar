=begin 

Lesli

Copyright (c) 2024, Lesli Technologies, S. A.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see http://www.gnu.org/licenses/.

Lesli · Ruby on Rails SaaS Development Framework.

Made with ♥ by LesliTech
Building a better future, one line of code at a time.

@contact  hello@lesli.tech
@website  https://www.lesli.tech
@license  GPLv3 http://www.gnu.org/licenses/gpl-3.0.en.html

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 
=end

module LesliCalendar
    class EventsController < ApplicationController
        before_action :set_event, only: %i[ show edit update destroy ]

        # GET /events
        def index
        @events = Event.all
        end

        # GET /events/1
        def show
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

            # Creating the event
            event_create_response = EventService.new(current_user).create(event_params)

            if event_create_response.successful?
                respond_with_successful(event_create_response)
            else
                respond_with_error(event_create_response.error.errors.full_messages.to_sentence)
            end
        end

            # PATCH/PUT /events/1
        def update
            if @event.update(event_params)
            redirect_to @event, notice: "Event was successfully updated.", status: :see_other
            else
            render :edit, status: :unprocessable_entity
            end
        end

        # DELETE /events/1
        def destroy
        @event.destroy
        redirect_to events_url, notice: "Event was successfully destroyed.", status: :see_other
        end

        private
        # Use callbacks to share common setup or constraints between actions.
        def set_event
        @event = Event.find(params[:id])
        end

        # Only allow a list of trusted parameters through.
        def event_params
            params.require(:event).permit(
                :id,
                :title,
                :description,
                :location,
                :status,
                :public,
                :start,
                :end,
                :url
            )
        end
    end
end
