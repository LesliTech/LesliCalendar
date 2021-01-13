=begin

Copyright (c) 2020, all rights reserved.

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
    class Workflow::Association < Shared::Workflow::Association
        belongs_to :workflow, class_name: "Workflow", foreign_key: "cloud_driver_workflows_id"

        # @return [Hash] A list of all available associations that can be created
        # @description Returns a hash where the key is the condensed name of the association and the value is the same.
        #     This previously was an enum that was changed due to issues with the new version of rails 6.1.0
        # @example
        #     CloudDriver::Workflow.first.associations.create!(
        #         workflow_for: CloudDriver::Workflow::Association.object_associations[:calendar],
        #         global: true
        #     )
        def self.object_associations
            return {
                calendar: "calendar",
                event: "event"
            }
        end
    end
end
