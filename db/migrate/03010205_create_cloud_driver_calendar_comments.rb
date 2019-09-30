class CreateCloudDriverCalendarComments < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_driver_calendar_comments do |t|
            t.timestamps
        end
        add_reference :cloud_driver_calendar_comments, :cloud_driver_calendars, foreign_key: true, index: { name: "calendar_comments_calendars" }
    end
end
