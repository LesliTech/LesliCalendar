module CloudDriver
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
    class Workflow::Status < Shared::Workflow::Status
        belongs_to :workflow, inverse_of: :statuses, class_name: "Workflow", foreign_key: "cloud_driver_workflows_id"
        belongs_to :workflow_including_deleted, class_name: "Workflow", foreign_key: "cloud_driver_workflows_id", with_deleted: true, optional: true
    end
end
