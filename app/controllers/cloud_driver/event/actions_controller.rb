require_dependency "cloud_driver/application_controller"

module CloudDriver
  class Event::ActionsController < ApplicationController
    before_action :set_event_action, only: [:show, :edit, :update, :destroy]

    # GET /event/actions
    def index
      @event_actions = Event::Action.all
    end

    # GET /event/actions/1
    def show
    end

    # GET /event/actions/new
    def new
      @event_action = Event::Action.new
    end

    # GET /event/actions/1/edit
    def edit
    end

    # POST /event/actions
    def create
      @event_action = Event::Action.new(event_action_params)

      if @event_action.save
        redirect_to @event_action, notice: 'Action was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /event/actions/1
    def update
      if @event_action.update(event_action_params)
        redirect_to @event_action, notice: 'Action was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /event/actions/1
    def destroy
      @event_action.destroy
      redirect_to event_actions_url, notice: 'Action was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_event_action
        @event_action = Event::Action.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def event_action_params
        params.fetch(:event_action, {})
      end
  end
end
