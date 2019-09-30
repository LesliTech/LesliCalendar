require_dependency "cloud_driver/application_controller"

module CloudDriver
  class Event::CommentsController < ApplicationController
    before_action :set_event_comment, only: [:show, :edit, :update, :destroy]

    # GET /event/comments
    def index
      @event_comments = Event::Comment.all
    end

    # GET /event/comments/1
    def show
    end

    # GET /event/comments/new
    def new
      @event_comment = Event::Comment.new
    end

    # GET /event/comments/1/edit
    def edit
    end

    # POST /event/comments
    def create
      @event_comment = Event::Comment.new(event_comment_params)

      if @event_comment.save
        redirect_to @event_comment, notice: 'Comment was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /event/comments/1
    def update
      if @event_comment.update(event_comment_params)
        redirect_to @event_comment, notice: 'Comment was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /event/comments/1
    def destroy
      @event_comment.destroy
      redirect_to event_comments_url, notice: 'Comment was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_event_comment
        @event_comment = Event::Comment.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def event_comment_params
        params.fetch(:event_comment, {})
      end
  end
end
