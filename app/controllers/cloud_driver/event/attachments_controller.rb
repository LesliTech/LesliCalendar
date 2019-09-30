require_dependency "cloud_driver/application_controller"

module CloudDriver
  class Event::AttachmentsController < ApplicationController
    before_action :set_event_attachment, only: [:show, :edit, :update, :destroy]

    # GET /event/attachments
    def index
      @event_attachments = Event::Attachment.all
    end

    # GET /event/attachments/1
    def show
    end

    # GET /event/attachments/new
    def new
      @event_attachment = Event::Attachment.new
    end

    # GET /event/attachments/1/edit
    def edit
    end

    # POST /event/attachments
    def create
      @event_attachment = Event::Attachment.new(event_attachment_params)

      if @event_attachment.save
        redirect_to @event_attachment, notice: 'Attachment was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /event/attachments/1
    def update
      if @event_attachment.update(event_attachment_params)
        redirect_to @event_attachment, notice: 'Attachment was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /event/attachments/1
    def destroy
      @event_attachment.destroy
      redirect_to event_attachments_url, notice: 'Attachment was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_event_attachment
        @event_attachment = Event::Attachment.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def event_attachment_params
        params.fetch(:event_attachment, {})
      end
  end
end
