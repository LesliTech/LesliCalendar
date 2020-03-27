require_dependency "cloud_driver/application_controller"

module CloudDriver
    class CalendarsController < ApplicationController
        before_action :set_calendar, only: [:show, :edit, :update, :destroy]

        # GET /calendars
        def index
            respond_to do |format|
                format.html { }
                format.json do
                    responseWithSuccessful(current_user.account.driver.calendars.joins(:detail).select(:id, :name, :color))
                end
            end
        end

        # GET /calendars/1
        def show
            respond_to do |format|
                format.html { }
                format.json do
                    responseWithSuccessful(Calendar.events_from_all_modules(current_user, @query))
                end
            end
        end

        # GET /calendars/new
        def new
            @calendar = Calendar.new
        end

        # GET /calendars/1/edit
        def edit
        end

        # POST /calendars
        def create
            @calendar = Calendar.new(calendar_params)
            if @calendar.save
                redirect_to @calendar, notice: 'Calendar was successfully created.'
            else
                render :new
            end
        end

        # PATCH/PUT /calendars/1
        def update
            if @calendar.update(calendar_params)
                redirect_to @calendar, notice: 'Calendar was successfully updated.'
            else
                render :edit
            end
        end

        # DELETE /calendars/1
        def destroy
            @calendar.destroy
            redirect_to calendars_url, notice: 'Calendar was successfully destroyed.'
        end

        private

        # Use callbacks to share common setup or constraints between actions.
        def set_calendar

            if params[:id].blank? || params[:id] == "default"
                @calendar = current_user.account.driver.calendars.default
            end

            #id = params[:id]
            #@calendar = current_user.account.driver.calendars.default if id == "default"
            #@calendar = Calendar.find(params[:id]) if id != "default"

            @calendar

        end

        # Only allow a trusted parameter "white list" through.
        def calendar_params
            params.fetch(:calendar, {})
        end
    end
end
