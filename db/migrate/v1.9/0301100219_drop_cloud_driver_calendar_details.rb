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

class DropCloudDriverCalendarDetails < ActiveRecord::Migration[7.0]
    def change
        add_column :cloud_driver_calendars, :name, :string
        add_column :cloud_driver_calendars, :color, :string, default: '100,100,200'
        add_column :cloud_driver_calendars, :default, :boolean, default: false
        add_column :cloud_driver_calendars, :active, :boolean, default: true

        CloudDriver::Calendar.all.each do |calendar|
            calendar.name = calendar.detail.name
            calendar.color = calendar.detail.color
            calendar.default = calendar.detail.default
            calendar.active = calendar.detail.active
            calendar.save!
        end

        drop_table :cloud_driver_calendar_details
    end
end
