=begin
Copyright (c) 2022, all rights reserved.

All the information provided by this platform is protected by international laws related  to
industrial property, intellectual property, copyright and relative international laws.
All intellectual or industrial property rights of the code, texts, trade mark, design,
pictures and any other information belongs to the owner of this platform.

Without the written permission of the owner, any replication, modification,
transmission, publication is strictly forbidden.

For more information read the license file including with this software.

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// ·

=end
require_dependency "cloud_driver/application_controller"

module CloudDriver
  class Event::ProposalsController < ApplicationController
      before_action :set_event_proposal, only: [:show, :update, :destroy]

      # GET /event/proposals
      def index
          respond_to do |format|
              format.html {}
              format.json do
                  respond_with_successful(Event::Proposal.index(current_user, @query))
              end
          end
      end

      # GET /event/proposals/1
      def show
          respond_to do |format|
              format.html {}
              format.json do
                  return respond_with_not_found unless @event_proposal
                  return respond_with_successful(@event_proposal.show(current_user, @query))
              end
          end
      end

      # GET /event/proposals/new
      def new
      end

      # GET /event/proposals/1/edit
      def edit
      end

      # POST /event/proposals
      def create
          event_proposal = Event::Proposal.new(event_proposal_params)
          if event_proposal.save
              respond_with_successful(event_proposal)
          else
              respond_with_error(event_proposal.errors.full_messages.to_sentence)
          end
      end

      # PATCH/PUT /event/proposals/1
      def update
          return respond_with_not_found unless @event_proposal

          if @event_proposal.update(event_proposal_params)
              respond_with_successful(@event_proposal.show(current_user, @query))
          else
              respond_with_error(@event_proposal.errors.full_messages.to_sentence)
          end
      end

      # DELETE /event/proposals/1
      def destroy
          return respond_with_not_found unless @event_proposal

          if @event_proposal.destroy
              respond_with_successful
          else
              respond_with_error(@event_proposal.errors.full_messages.to_sentence)
          end
      end

      private

      # Use callbacks to share common setup or constraints between actions.
      def set_event_proposal
          @event_proposal = current_user.account.event_proposals.find_by_id(params[:id])
      end

      # Only allow a list of trusted parameters through.
      def event_proposal_params
          params.fetch(:event_proposal, {}).permit(:id, :name)
      end
  end
end
