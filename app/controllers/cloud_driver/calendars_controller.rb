=begin

Copyright (c) 2023, all rights reserved.

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
    class CalendarsController < ApplicationController
        before_action :set_calendar, only: [:show, :edit, :update]
        before_action :parse_query_params, only: :show

        # GET /calendars
        def index
            respond_to do |format|
                format.html { }
                format.json do
                    respond_with_pagination(CloudDriver::CalendarService.new(current_user).index(@query))
                end
            end
        end

        # GET /calendars/1
        def show
            respond_to do |format|
                format.html { }
                format.json { respond_with_successful(@calendar.show(@query)) }
            end
        end

        # GET /calendars/new
        def new
        end

        # GET /calendars/1/edit
        def edit
        end

        # POST /calendars
        def create
        end

        # PATCH/PUT /calendars/1
        def update
        end

        # DELETE /calendars/1
        def destroy
        end

        def options
            respond_with_successful(Calendar.options(current_user, @query))
        end

        def sync
            respond_with_successful(Calendar.sync(current_user))
        end

        private

        # @return [void]
        # @description Sets the requested user based on the current_users's account
        # @example
        #     # Executing this method from a controller action:
        #     set_calendar
        #     puts @calendar
        #     # This will either display nil or an instance of CloudDriver::Calendar
        def set_calendar
            if params[:id].blank? || params[:id] == "default"
                @calendar = CloudDriver::CalendarService.new(current_user).default_calendar
            elsif params[:id]
                @calendar = CloudDriver::CalendarService.new(current_user).find(params[:id])
            end

            return respond_with_not_found unless @calendar
        end

        # Only allow a trusted parameter "white list" through.
        def calendar_params
            params.require(:calendar)
        end

        def parse_query_params
            @query[:filters][:start_date] = @query[:filters][:start_date].to_datetime if @query[:filters][:start_date]
            @query[:filters][:end_date] = @query[:filters][:end_date].to_datetime if @query[:filters][:end_date]
        end
    end
end
