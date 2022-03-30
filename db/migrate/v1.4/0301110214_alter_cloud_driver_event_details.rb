class AlterCloudDriverEventDetails < ActiveRecord::Migration[7.0]
    def change
        add_column :cloud_driver_event_details, :privacy, :string
        add_column :cloud_driver_event_details, :budget, :string
    end
end
