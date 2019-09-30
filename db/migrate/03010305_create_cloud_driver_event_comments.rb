class CreateCloudDriverEventComments < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_driver_event_comments do |t|
            t.timestamps
        end
        add_reference :cloud_driver_event_comments, :cloud_driver_events, foreign_key: true
    end
end
