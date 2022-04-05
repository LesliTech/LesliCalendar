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

class AlterCloudDriverEventDetails < ActiveRecord::Migration[7.0]
    def change
        change_column :cloud_driver_event_details,  :budget,    "numeric USING CAST(budget AS numeric)"
        add_column :cloud_driver_event_details,     :real_cost, :decimal

        add_column :cloud_driver_event_details,     :signed_up_count, :integer
        add_column :cloud_driver_event_details,     :showed_up_count, :integer
    end
end
