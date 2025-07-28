module LesliCalendar
  class Event::AttendantsController < ApplicationController
    before_action :set_event_attendant, only: %i[ show edit update destroy ]

    # GET /event/attendants
    def index
      @event_attendants = Event::Attendant.all
    end

    # GET /event/attendants/1
    def show
    end

    # GET /event/attendants/new
    def new
      @event_attendant = Event::Attendant.new
    end

    # GET /event/attendants/1/edit
    def edit
    end

    # POST /event/attendants
    def create
      @event_attendant = Event::Attendant.new(event_attendant_params)

      if @event_attendant.save
        redirect_to @event_attendant, notice: "Attendant was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /event/attendants/1
    def update
      if @event_attendant.update(event_attendant_params)
        redirect_to @event_attendant, notice: "Attendant was successfully updated.", status: :see_other
      else
        render :edit, status: :unprocessable_entity
      end
    end

    # DELETE /event/attendants/1
    def destroy
      @event_attendant.destroy
      redirect_to event_attendants_url, notice: "Attendant was successfully destroyed.", status: :see_other
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_event_attendant
        @event_attendant = Event::Attendant.find(params[:id])
      end

      # Only allow a list of trusted parameters through.
      def event_attendant_params
        params.fetch(:event_attendant, {})
      end
  end
end
