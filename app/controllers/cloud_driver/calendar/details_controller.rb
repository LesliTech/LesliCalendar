require_dependency "cloud_driver/application_controller"

module CloudDriver
  class Calendar::DetailsController < ApplicationController
    before_action :set_calendar_detail, only: [:show, :edit, :update, :destroy]

    # GET /calendar/details
    def index
      @calendar_details = Calendar::Detail.all
    end

    # GET /calendar/details/1
    def show
    end

    # GET /calendar/details/new
    def new
      @calendar_detail = Calendar::Detail.new
    end

    # GET /calendar/details/1/edit
    def edit
    end

    # POST /calendar/details
    def create
      @calendar_detail = Calendar::Detail.new(calendar_detail_params)

      if @calendar_detail.save
        redirect_to @calendar_detail, notice: 'Detail was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /calendar/details/1
    def update
      if @calendar_detail.update(calendar_detail_params)
        redirect_to @calendar_detail, notice: 'Detail was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /calendar/details/1
    def destroy
      @calendar_detail.destroy
      redirect_to calendar_details_url, notice: 'Detail was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_calendar_detail
        @calendar_detail = Calendar::Detail.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def calendar_detail_params
        params.fetch(:calendar_detail, {})
      end
  end
end
