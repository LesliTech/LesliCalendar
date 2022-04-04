class AlterCloudDriverEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :cloud_driver_events, :source, :string
    add_column :cloud_driver_events, :external_uid, :string
  end
end
