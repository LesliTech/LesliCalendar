class CreateCloudDriverEvents < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_driver_events do |t|

            t.timestamps
        end
        add_reference :cloud_driver_events, :users, foreign_key: true, index: { name: "house_events_users" }
        add_reference :cloud_driver_events, :cloud_driver_calendars, foreign_key: true
        add_reference :cloud_driver_events, :accounts, foreign_key: true
        add_reference :cloud_driver_events, :model, polymorphic: true
        add_reference :cloud_driver_events, :organizer
    end
end
