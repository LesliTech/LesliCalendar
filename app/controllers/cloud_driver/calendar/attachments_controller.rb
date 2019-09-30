require_dependency "cloud_driver/application_controller"

module CloudDriver
  class Calendar::AttachmentsController < ApplicationController
    before_action :set_calendar_attachment, only: [:show, :edit, :update, :destroy]

    # GET /calendar/attachments
    def index
      @calendar_attachments = Calendar::Attachment.all
    end

    # GET /calendar/attachments/1
    def show
    end

    # GET /calendar/attachments/new
    def new
      @calendar_attachment = Calendar::Attachment.new
    end

    # GET /calendar/attachments/1/edit
    def edit
    end

    # POST /calendar/attachments
    def create
      @calendar_attachment = Calendar::Attachment.new(calendar_attachment_params)

      if @calendar_attachment.save
        redirect_to @calendar_attachment, notice: 'Attachment was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /calendar/attachments/1
    def update
      if @calendar_attachment.update(calendar_attachment_params)
        redirect_to @calendar_attachment, notice: 'Attachment was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /calendar/attachments/1
    def destroy
      @calendar_attachment.destroy
      redirect_to calendar_attachments_url, notice: 'Attachment was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_calendar_attachment
        @calendar_attachment = Calendar::Attachment.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def calendar_attachment_params
        params.fetch(:calendar_attachment, {})
      end
  end
end
