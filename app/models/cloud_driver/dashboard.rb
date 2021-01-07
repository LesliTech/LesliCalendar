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
    class Dashboard < Shared::Dashboard
        belongs_to :account, class_name: "Account", foreign_key: "cloud_driver_accounts_id"
        
        has_many :components, inverse_of: :dashboard, autosave: true, class_name: "Dashboard::Component", foreign_key: "cloud_driver_dashboards_id", dependent: :destroy
        accepts_nested_attributes_for :components, allow_destroy: true
    end
end
