module LesliCalendar
  class Event::GuestsController < ApplicationController
    before_action :set_event_guest, only: %i[ show edit update destroy ]

    # GET /event/guests
    def index
      @event_guests = Event::Guest.all
    end

    # GET /event/guests/1
    def show
    end

    # GET /event/guests/new
    def new
      @event_guest = Event::Guest.new
    end

    # GET /event/guests/1/edit
    def edit
    end

    # POST /event/guests
    def create
      @event_guest = Event::Guest.new(event_guest_params)

      if @event_guest.save
        redirect_to @event_guest, notice: "Guest was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /event/guests/1
    def update
      if @event_guest.update(event_guest_params)
        redirect_to @event_guest, notice: "Guest was successfully updated.", status: :see_other
      else
        render :edit, status: :unprocessable_entity
      end
    end

    # DELETE /event/guests/1
    def destroy
      @event_guest.destroy
      redirect_to event_guests_url, notice: "Guest was successfully destroyed.", status: :see_other
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_event_guest
        @event_guest = Event::Guest.find(params[:id])
      end

      # Only allow a list of trusted parameters through.
      def event_guest_params
        params.fetch(:event_guest, {})
      end
  end
end
