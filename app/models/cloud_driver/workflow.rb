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
    class Workflow < CloudObject::Workflow
        belongs_to :account, class_name: "Account", foreign_key: "cloud_driver_accounts_id"
        has_many :associations, class_name: "Workflow::Association", foreign_key: "cloud_driver_workflows_id"
        has_many :actions, class_name: "Workflow::Action", foreign_key: "cloud_driver_workflows_id"
        
        has_many(
            :statuses,
            inverse_of: :workflow,
            class_name: "Workflow::Status",
            foreign_key: "cloud_driver_workflows_id",
            autosave: true,
            dependent: :delete_all
        )

        accepts_nested_attributes_for :statuses, allow_destroy: true
    end
end
