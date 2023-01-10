=begin

Copyright (c) 2023, all rights reserved.

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

module CloudDriver
    class Event::ProposalServices

        def self.create(current_user, events_id, event_proposal_params)
            # Looking for the event
            event = Courier::Driver::Event.find(current_user, events_id)

            return LC::Response.service(false) unless event

            # Creating the event proposal
            event_proposal = event.proposals.new(event_proposal_params)
            event_proposal.user = current_user

            if event_proposal.save
                return LC::Response.service(true, event_proposal)
            end

            return LC::Response.service(false, event_proposal)
        end

    end
end
