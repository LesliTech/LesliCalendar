class CreateCloudDriverEventAttendants < ActiveRecord::Migration[6.0]
  def change
    create_table :cloud_driver_event_attendants do |t|
      t.timestamps
    end
    add_reference :cloud_driver_event_attendants, :cloud_driver_events, foreign_key: true
    add_reference :cloud_driver_event_attendants, :users, foreign_key: true
  end
end
