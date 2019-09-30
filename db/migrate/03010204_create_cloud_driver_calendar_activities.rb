class CreateCloudDriverCalendarActivities < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_driver_calendar_activities do |t|
            t.timestamps
        end
        add_reference :cloud_driver_calendar_activities, :cloud_driver_calendars, foreign_key: true, index: { name: "calendar_activities_calendars" }
    end
end
