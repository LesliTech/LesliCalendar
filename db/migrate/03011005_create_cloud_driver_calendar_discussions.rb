class CreateCloudDriverCalendarDiscussions < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_driver_calendar_discussions do |t|
            table_base_structure = JSON.parse(File.read(Rails.root.join('db','structure','00000005_discussions.json')))
            table_base_structure.each do |column|
                t.send(
                    column["type"].parameterize.underscore.to_sym,
                    column["name"].parameterize.underscore.to_sym
                )
            end
            t.timestamps
        end
        add_reference :cloud_driver_calendar_discussions, :users, foreign_key: true
        add_reference :cloud_driver_calendar_discussions, :cloud_driver_calendar_discussions, foreign_key: true, index: { name: "driver_calendar_discussions_calendar_discussions" }
        add_reference :cloud_driver_calendar_discussions, :cloud_driver_calendars, foreign_key: true, index: { name: "driver_calendar_discussions_calendars" }
    end
end
