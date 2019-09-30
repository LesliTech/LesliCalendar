require_dependency "cloud_driver/application_controller"

module CloudDriver
  class Event::DetailsController < ApplicationController
    before_action :set_event_detail, only: [:show, :edit, :update, :destroy]

    # GET /event/details
    def index
      @event_details = Event::Detail.all
    end

    # GET /event/details/1
    def show
    end

    # GET /event/details/new
    def new
      @event_detail = Event::Detail.new
    end

    # GET /event/details/1/edit
    def edit
    end

    # POST /event/details
    def create
      @event_detail = Event::Detail.new(event_detail_params)

      if @event_detail.save
        redirect_to @event_detail, notice: 'Detail was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /event/details/1
    def update
      if @event_detail.update(event_detail_params)
        redirect_to @event_detail, notice: 'Detail was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /event/details/1
    def destroy
      @event_detail.destroy
      redirect_to event_details_url, notice: 'Detail was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_event_detail
        @event_detail = Event::Detail.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def event_detail_params
        params.fetch(:event_detail, {})
      end
  end
end
