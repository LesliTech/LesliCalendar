require_dependency "cloud_driver/application_controller"

module CloudDriver
  class Calendar::DiscussionsController < ApplicationController
    before_action :set_calendar_discussion, only: [:show, :edit, :update, :destroy]

    # GET /calendar/discussions
    def index
      @calendar_discussions = Calendar::Discussion.all
    end

    # GET /calendar/discussions/1
    def show
    end

    # GET /calendar/discussions/new
    def new
      @calendar_discussion = Calendar::Discussion.new
    end

    # GET /calendar/discussions/1/edit
    def edit
    end

    # POST /calendar/discussions
    def create
      @calendar_discussion = Calendar::Discussion.new(calendar_discussion_params)

      if @calendar_discussion.save
        redirect_to @calendar_discussion, notice: 'Discussion was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /calendar/discussions/1
    def update
      if @calendar_discussion.update(calendar_discussion_params)
        redirect_to @calendar_discussion, notice: 'Discussion was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /calendar/discussions/1
    def destroy
      @calendar_discussion.destroy
      redirect_to calendar_discussions_url, notice: 'Discussion was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_calendar_discussion
        @calendar_discussion = Calendar::Discussion.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def calendar_discussion_params
        params.fetch(:calendar_discussion, {})
      end
  end
end
