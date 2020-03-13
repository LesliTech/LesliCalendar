require_dependency "cloud_driver/application_controller"

module CloudDriver
  class Event::SubscriptionsController < ApplicationController
    before_action :set_event_subscription, only: [:show, :edit, :update, :destroy]

    # GET /event/subscriptions
    def index
      @event_subscriptions = Event::Subscription.all
    end

    # GET /event/subscriptions/1
    def show
    end

    # GET /event/subscriptions/new
    def new
      @event_subscription = Event::Subscription.new
    end

    # GET /event/subscriptions/1/edit
    def edit
    end

    # POST /event/subscriptions
    def create
      @event_subscription = Event::Subscription.new(event_subscription_params)

      if @event_subscription.save
        redirect_to @event_subscription, notice: 'Subscription was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /event/subscriptions/1
    def update
      if @event_subscription.update(event_subscription_params)
        redirect_to @event_subscription, notice: 'Subscription was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /event/subscriptions/1
    def destroy
      @event_subscription.destroy
      redirect_to event_subscriptions_url, notice: 'Subscription was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_event_subscription
        @event_subscription = Event::Subscription.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def event_subscription_params
        params.fetch(:event_subscription, {})
      end
  end
end
