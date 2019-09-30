require_dependency "cloud_driver/application_controller"

module CloudDriver
  class Calendar::ActivitiesController < ApplicationController
    before_action :set_calendar_activity, only: [:show, :edit, :update, :destroy]

    # GET /calendar/activities
    def index
      @calendar_activities = Calendar::Activity.all
    end

    # GET /calendar/activities/1
    def show
    end

    # GET /calendar/activities/new
    def new
      @calendar_activity = Calendar::Activity.new
    end

    # GET /calendar/activities/1/edit
    def edit
    end

    # POST /calendar/activities
    def create
      @calendar_activity = Calendar::Activity.new(calendar_activity_params)

      if @calendar_activity.save
        redirect_to @calendar_activity, notice: 'Activity was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /calendar/activities/1
    def update
      if @calendar_activity.update(calendar_activity_params)
        redirect_to @calendar_activity, notice: 'Activity was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /calendar/activities/1
    def destroy
      @calendar_activity.destroy
      redirect_to calendar_activities_url, notice: 'Activity was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_calendar_activity
        @calendar_activity = Calendar::Activity.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def calendar_activity_params
        params.fetch(:calendar_activity, {})
      end
  end
end
