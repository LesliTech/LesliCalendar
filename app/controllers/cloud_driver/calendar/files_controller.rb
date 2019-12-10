require_dependency "cloud_driver/application_controller"

module CloudDriver
  class Calendar::FilesController < ApplicationController
    before_action :set_calendar_file, only: [:show, :edit, :update, :destroy]

    # GET /calendar/files
    def index
      @calendar_files = Calendar::File.all
    end

    # GET /calendar/files/1
    def show
    end

    # GET /calendar/files/new
    def new
      @calendar_file = Calendar::File.new
    end

    # GET /calendar/files/1/edit
    def edit
    end

    # POST /calendar/files
    def create
      @calendar_file = Calendar::File.new(calendar_file_params)

      if @calendar_file.save
        redirect_to @calendar_file, notice: 'File was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /calendar/files/1
    def update
      if @calendar_file.update(calendar_file_params)
        redirect_to @calendar_file, notice: 'File was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /calendar/files/1
    def destroy
      @calendar_file.destroy
      redirect_to calendar_files_url, notice: 'File was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_calendar_file
        @calendar_file = Calendar::File.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def calendar_file_params
        params.fetch(:calendar_file, {})
      end
  end
end
