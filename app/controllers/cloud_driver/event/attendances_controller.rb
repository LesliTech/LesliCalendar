require_dependency "cloud_driver/application_controller"

module CloudDriver
  class Event::AttendancesController < ApplicationController
    before_action :set_event_attendance, only: [:show, :edit, :update, :destroy]

    # GET /event/attendances
    def index
      @event_attendances = Event::Attendance.all
    end

    # GET /event/attendances/1
    def show
    end

    # GET /event/attendances/new
    def new
      @event_attendance = Event::Attendance.new
    end

    # GET /event/attendances/1/edit
    def edit
    end

    # POST /event/attendances
    def create
      @event_attendance = Event::Attendance.new(event_attendance_params)

      if @event_attendance.save
        redirect_to @event_attendance, notice: 'Attendance was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /event/attendances/1
    def update
      if @event_attendance.update(event_attendance_params)
        redirect_to @event_attendance, notice: 'Attendance was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /event/attendances/1
    def destroy
      @event_attendance.destroy
      redirect_to event_attendances_url, notice: 'Attendance was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_event_attendance
        @event_attendance = Event::Attendance.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def event_attendance_params
        params.fetch(:event_attendance, {})
      end
  end
end
