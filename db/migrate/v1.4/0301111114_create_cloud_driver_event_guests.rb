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
class CreateCloudDriverEventGuests < ActiveRecord::Migration[7.0]
    def change
        create_table :cloud_driver_event_guests do |t|
            t.string    :name
            t.string    :email
            t.string    :token
            t.datetime  :confirmed_at, index: true
            t.timestamps
        end
        add_reference :cloud_driver_event_guests, :cloud_driver_events, foreign_key: true
    end
end
