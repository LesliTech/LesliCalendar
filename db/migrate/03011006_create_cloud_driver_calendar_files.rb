class CreateCloudDriverCalendarFiles < ActiveRecord::Migration[6.0]
    def change
        table_base_structure = JSON.parse(File.read(Rails.root.join('db','structure','00000006_files.json')))
        create_table :cloud_driver_calendar_files do |t|
            table_base_structure.each do |column|
                t.send(
                    column["type"].parameterize.underscore.to_sym,
                    column["name"].parameterize.underscore.to_sym
                )
            end
            t.timestamps
        end
        add_reference :cloud_driver_calendar_files, :cloud_driver_calendars, foreign_key: true
    end
end
