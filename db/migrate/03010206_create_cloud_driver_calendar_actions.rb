class CreateCloudDriverCalendarActions < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_driver_calendar_actions do |t|
            t.timestamps
        end
        add_reference :cloud_driver_calendar_actions, :cloud_driver_calendars, foreign_key: true, index: { name: "calendar_actions_calendars" }
    end
end
