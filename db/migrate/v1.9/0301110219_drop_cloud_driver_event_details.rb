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

class DropCloudDriverEventDetails < ActiveRecord::Migration[7.0]
    def change
        add_column :cloud_driver_events, :title, :string, required: true
        add_column :cloud_driver_events, :description, :text
        add_column :cloud_driver_events, :event_date, :datetime
        add_column :cloud_driver_events, :time_start, :datetime
        add_column :cloud_driver_events, :time_end, :datetime
        add_column :cloud_driver_events, :location, :string
        add_column :cloud_driver_events, :url, :string
        add_column :cloud_driver_events, :public, :boolean
        add_column :cloud_driver_events, :privacy, :string
        add_column :cloud_driver_events, :budget, :decimal
        add_column :cloud_driver_events, :region, :string
        add_column :cloud_driver_events, :real_cost, :decimal
        add_column :cloud_driver_events, :signed_up_count, :integer
        add_column :cloud_driver_events, :showed_up_count, :integer

        CloudDriver::Event.all.each do |event|
            event.title = event.detail.title
            event.title = event.detail.title
            event.description = event.detail.description
            event.event_date = event.detail.event_date
            event.time_start = event.detail.time_start
            event.time_end = event.detail.time_end
            event.location = event.detail.location
            event.url = event.detail.url
            event.public = event.detail.public
            event.privacy = event.detail.privacy
            event.budget = event.detail.budget
            event.region = event.detail.region
            event.real_cost = event.detail.real_cost
            event.signed_up_count = event.detail.signed_up_count
            event.showed_up_count = event.detail.showed_up_count
            event.save!
        end

        drop_table :cloud_driver_event_details
    end
end
