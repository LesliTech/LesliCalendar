class CreateCloudDriverCalendars < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_driver_calendars do |t|
            # acts_as_paranoid
            t.datetime :deleted_at, index: true
            
            t.timestamps
        end
        add_reference :cloud_driver_calendars, :cloud_driver_accounts, foreign_key: true
        add_reference :cloud_driver_calendars, :cloud_driver_workflow_statuses, foreign_key: true, index: { name: "driver_calendars_workflow_statuses" }
    end
end
