require_dependency "cloud_driver/application_controller"

module CloudDriver
  class Calendar::SubscribersController < ApplicationController
    before_action :set_calendar_subscriber, only: [:show, :edit, :update, :destroy]

    # GET /calendar/subscribers
    def index
      @calendar_subscribers = Calendar::Subscriber.all
    end

    # GET /calendar/subscribers/1
    def show
    end

    # GET /calendar/subscribers/new
    def new
      @calendar_subscriber = Calendar::Subscriber.new
    end

    # GET /calendar/subscribers/1/edit
    def edit
    end

    # POST /calendar/subscribers
    def create
      @calendar_subscriber = Calendar::Subscriber.new(calendar_subscriber_params)

      if @calendar_subscriber.save
        redirect_to @calendar_subscriber, notice: 'Subscriber was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /calendar/subscribers/1
    def update
      if @calendar_subscriber.update(calendar_subscriber_params)
        redirect_to @calendar_subscriber, notice: 'Subscriber was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /calendar/subscribers/1
    def destroy
      @calendar_subscriber.destroy
      redirect_to calendar_subscribers_url, notice: 'Subscriber was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_calendar_subscriber
        @calendar_subscriber = Calendar::Subscriber.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def calendar_subscriber_params
        params.fetch(:calendar_subscriber, {})
      end
  end
end
