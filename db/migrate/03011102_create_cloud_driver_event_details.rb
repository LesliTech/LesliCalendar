class CreateCloudDriverEventDetails < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_driver_event_details do |t|
            t.string    :title, required: true
            t.text      :description
            t.datetime  :event_date
            t.datetime  :time_start
            t.datetime  :time_end
            t.string    :location
            t.string    :url
            t.string    :event_type
            t.boolean   :public

            # acts_as_paranoid
            t.datetime :deleted_at, index: true

            t.timestamps
        end
        add_reference :cloud_driver_event_details, :cloud_driver_events, foreign_key: true
    end
end
