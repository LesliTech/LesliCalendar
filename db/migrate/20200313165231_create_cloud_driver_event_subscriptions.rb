class CreateCloudDriverEventSubscriptions < ActiveRecord::Migration[6.0]
  def change
    create_table :cloud_driver_event_subscriptions do |t|

      t.timestamps
    end
  end
end
