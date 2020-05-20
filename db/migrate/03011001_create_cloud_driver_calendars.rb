class CreateCloudDriverCalendars < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_driver_calendars do |t|
            # acts_as_paranoid
            t.datetime :deleted_at, index: true
            
            t.timestamps
        end
        add_reference :cloud_driver_calendars, :cloud_driver_accounts, foreign_key: true
    end
end
