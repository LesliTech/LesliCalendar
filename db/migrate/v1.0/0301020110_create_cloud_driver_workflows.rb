class CreateCloudDriverWorkflows < ActiveRecord::Migration[6.0]
    def change
        table_base_structure = JSON.parse(File.read(Rails.root.join("db","structure","00000201_workflows.json")))
        create_table :cloud_driver_workflows do |t|
            table_base_structure.each do |column|
                t.send(
                    column["type"].parameterize.underscore.to_sym,
                    column["name"].parameterize.underscore.to_sym
                )
            end
            
            t.timestamps
        end
        add_reference :cloud_driver_workflows, :cloud_driver_accounts, foreign_key: true, index: { name: "driver_workflows_accounts" }
    end
end
