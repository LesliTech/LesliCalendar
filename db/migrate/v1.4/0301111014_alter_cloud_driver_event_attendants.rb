class AlterCloudDriverEventAttendants < ActiveRecord::Migration[7.0]
    def change
        add_column :cloud_driver_event_attendants, :confirmed_at, :datetime
    end
end
