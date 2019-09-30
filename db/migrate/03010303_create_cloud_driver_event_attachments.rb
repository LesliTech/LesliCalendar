class CreateCloudDriverEventAttachments < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_driver_event_attachments do |t|
            t.timestamps
        end
        add_reference :cloud_driver_event_attachments, :cloud_driver_events, foreign_key: true
    end
end
