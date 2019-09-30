require_dependency "cloud_driver/application_controller"

module CloudDriver
  class Calendar::ActionsController < ApplicationController
    before_action :set_calendar_action, only: [:show, :edit, :update, :destroy]

    # GET /calendar/actions
    def index
      @calendar_actions = Calendar::Action.all
    end

    # GET /calendar/actions/1
    def show
    end

    # GET /calendar/actions/new
    def new
      @calendar_action = Calendar::Action.new
    end

    # GET /calendar/actions/1/edit
    def edit
    end

    # POST /calendar/actions
    def create
      @calendar_action = Calendar::Action.new(calendar_action_params)

      if @calendar_action.save
        redirect_to @calendar_action, notice: 'Action was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /calendar/actions/1
    def update
      if @calendar_action.update(calendar_action_params)
        redirect_to @calendar_action, notice: 'Action was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /calendar/actions/1
    def destroy
      @calendar_action.destroy
      redirect_to calendar_actions_url, notice: 'Action was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_calendar_action
        @calendar_action = Calendar::Action.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def calendar_action_params
        params.fetch(:calendar_action, {})
      end
  end
end
