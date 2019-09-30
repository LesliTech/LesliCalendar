class CreateCloudDriverCalendarDetails < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_driver_calendar_details do |t|
            t.timestamps
        end
        add_reference :cloud_driver_calendar_details, :cloud_driver_calendars, foreign_key: true, index: { name: "calendar_details_calendars" }
    end
end
