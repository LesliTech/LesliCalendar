class CreateCloudDriverEvents < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_driver_events do |t|
            # acts_as_paranoid
            t.datetime  :deleted_at, index: true
            
            # Main user
            t.bigint :users_main_id

            t.timestamps
        end
        add_reference   :cloud_driver_events, :cloud_driver_accounts, foreign_key: true
        add_reference   :cloud_driver_events, :users, foreign_key: true, index: { name: "driver_events_users" }
        add_foreign_key :cloud_driver_events, :users, column: :users_main_id
        add_reference   :cloud_driver_events, :cloud_driver_workflow_statuses, foreign_key: true, index: { name: "driver_events_workflow_statuses" }
        add_reference   :cloud_driver_events, :cloud_driver_calendars, foreign_key: true
        
        add_reference   :cloud_driver_events, :model, polymorphic: true
    end
end
