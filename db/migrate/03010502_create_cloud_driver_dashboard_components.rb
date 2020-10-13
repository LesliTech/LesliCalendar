class CreateCloudDriverDashboardComponents < ActiveRecord::Migration[6.0]
    def change
        table_base_structure = JSON.parse(File.read(Rails.root.join("db","structure","00000502_dashboard_components.json")))
        create_table :cloud_driver_dashboard_components do |t|
            table_base_structure.each do |column|
                t.send(
                    column["type"].parameterize.underscore.to_sym,
                    column["name"].parameterize.underscore.to_sym
                )
            end
            t.timestamps
        end
        
        add_reference :cloud_driver_dashboard_components, :cloud_driver_dashboards, foreign_key: true, index: { name: "driver_dashboard_components_dashboards" }
    end
end
