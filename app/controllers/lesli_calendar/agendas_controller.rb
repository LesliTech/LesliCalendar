module LesliCalendar
  class AgendasController < ApplicationController
    before_action :set_agenda, only: %i[ show edit update destroy ]

    # GET /agendas
    def index
      @agendas = Agenda.all
    end

    # GET /agendas/1
    def show
        @agenda = EventService.new(current_user, query).agenda
    end

    # GET /agendas/new
    def new
      @agenda = Agenda.new
    end

    # GET /agendas/1/edit
    def edit
    end

    # POST /agendas
    def create
      @agenda = Agenda.new(agenda_params)

      if @agenda.save
        redirect_to @agenda, notice: "Agenda was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /agendas/1
    def update
      if @agenda.update(agenda_params)
        redirect_to @agenda, notice: "Agenda was successfully updated.", status: :see_other
      else
        render :edit, status: :unprocessable_entity
      end
    end

    # DELETE /agendas/1
    def destroy
      @agenda.destroy
      redirect_to agendas_url, notice: "Agenda was successfully destroyed.", status: :see_other
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_agenda
        #@agenda = Agenda.find(params[:id])
      end

      # Only allow a list of trusted parameters through.
      def agenda_params
        params.fetch(:agenda, {})
      end
  end
end
