class CreateCloudDriverCalendarDetails < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_driver_calendar_details do |t|
            t.string :name
            t.string :color, default: '100,100,200'
            t.boolean :default, default: false
            t.boolean :active, default: true

            # acts_as_paranoid
            t.datetime :deleted_at, index: true
            
            t.timestamps
        end
        add_reference :cloud_driver_calendar_details, :cloud_driver_calendars, foreign_key: true, index: { name: "calendar_details_calendars" }
    end
end
