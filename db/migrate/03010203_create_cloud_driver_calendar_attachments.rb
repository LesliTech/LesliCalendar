class CreateCloudDriverCalendarAttachments < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_driver_calendar_attachments do |t|
            t.timestamps
        end
        add_reference :cloud_driver_calendar_attachments, :cloud_driver_calendars, foreign_key: true, index: { name: "calendar_attachments_calendars" }
    end
end
