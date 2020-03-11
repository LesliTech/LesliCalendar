class CreateCloudDriverEventAttendances < ActiveRecord::Migration[6.0]
  def change
    create_table :cloud_driver_event_attendances do |t|
      t.timestamps
    end
    add_reference :cloud_driver_event_attendances, :cloud_driver_events, foreign_key: true
    add_reference :cloud_driver_event_attendances, :users, foreign_key: true
  end
end
