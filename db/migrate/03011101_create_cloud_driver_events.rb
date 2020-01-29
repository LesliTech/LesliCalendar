class CreateCloudDriverEvents < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_driver_events do |t|
            t.timestamps
        end
        add_reference :cloud_driver_events, :cloud_driver_calendars, foreign_key: true
    end
end
