require_dependency "cloud_driver/application_controller"

module CloudDriver
  class Event::ActivitiesController < ApplicationController
    before_action :set_event_activity, only: [:show, :edit, :update, :destroy]

    # GET /event/activities
    def index
      @event_activities = Event::Activity.all
    end

    # GET /event/activities/1
    def show
    end

    # GET /event/activities/new
    def new
      @event_activity = Event::Activity.new
    end

    # GET /event/activities/1/edit
    def edit
    end

    # POST /event/activities
    def create
      @event_activity = Event::Activity.new(event_activity_params)

      if @event_activity.save
        redirect_to @event_activity, notice: 'Activity was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /event/activities/1
    def update
      if @event_activity.update(event_activity_params)
        redirect_to @event_activity, notice: 'Activity was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /event/activities/1
    def destroy
      @event_activity.destroy
      redirect_to event_activities_url, notice: 'Activity was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_event_activity
        @event_activity = Event::Activity.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def event_activity_params
        params.fetch(:event_activity, {})
      end
  end
end
