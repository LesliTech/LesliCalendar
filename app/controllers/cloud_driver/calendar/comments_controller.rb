require_dependency "cloud_driver/application_controller"

module CloudDriver
  class Calendar::CommentsController < ApplicationController
    before_action :set_calendar_comment, only: [:show, :edit, :update, :destroy]

    # GET /calendar/comments
    def index
      @calendar_comments = Calendar::Comment.all
    end

    # GET /calendar/comments/1
    def show
    end

    # GET /calendar/comments/new
    def new
      @calendar_comment = Calendar::Comment.new
    end

    # GET /calendar/comments/1/edit
    def edit
    end

    # POST /calendar/comments
    def create
      @calendar_comment = Calendar::Comment.new(calendar_comment_params)

      if @calendar_comment.save
        redirect_to @calendar_comment, notice: 'Comment was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /calendar/comments/1
    def update
      if @calendar_comment.update(calendar_comment_params)
        redirect_to @calendar_comment, notice: 'Comment was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /calendar/comments/1
    def destroy
      @calendar_comment.destroy
      redirect_to calendar_comments_url, notice: 'Comment was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_calendar_comment
        @calendar_comment = Calendar::Comment.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def calendar_comment_params
        params.fetch(:calendar_comment, {})
      end
  end
end
