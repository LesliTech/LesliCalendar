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
        before_action :set_event, only: [:create]
        before_action :set_event_proposal, only: [:show]

        def privileges
            {
                new: [],
            }
        end

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

        # POST /event/proposals
        def create
            return respond_with_error unless @event.is_proposal

            event_proposal = @event.proposals.new(event_proposal_params)
            event_proposal.rejected = false

            if event_proposal.save
                respond_with_successful(event_proposal)
            else
                respond_with_error(event_proposal.errors.full_messages.to_sentence)
            end
        end

        private

        def set_event
            @event = Event.find_by(
                id: params[:event_id],
                cloud_driver_accounts_id: current_user.account.id
            )
        end

        # Use callbacks to share common setup or constraints between actions.
        def set_event_proposal
            @event_proposal = current_user.account.event_proposals.find_by_id(params[:id])
        end

        # Only allow a list of trusted parameters through.
        def event_proposal_params
            params.fetch(:event_proposal, {}).permit(
                :id,
                :event_date,
                :time_start,
                :time_end,
            )
        end
    end
end
