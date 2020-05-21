class CreateCloudDriverCalendarActions < ActiveRecord::Migration[6.0]
    def change
        table_base_structure = JSON.parse(File.read(Rails.root.join('db','structure','00000003_actions.json')))
        create_table :cloud_driver_calendar_actions do |t|
            table_base_structure.each do |column|
                t.send(
                    column["type"].parameterize.underscore.to_sym,
                    column["name"].parameterize.underscore.to_sym
                )
            end
            
            # acts_as_paranoid
            t.datetime :deleted_at, index: true

            t.timestamps
        end
        add_reference :cloud_driver_calendar_actions, :cloud_driver_calendars, foreign_key: true, index: { name: "calendar_actions_calendars" }
    end
end
