class CreateCloudDriverWorkflowActions < ActiveRecord::Migration[6.0]
    def change
        table_base_structure = JSON.parse(File.read(Rails.root.join("db","structure","00000204_workflow_actions.json")))
        create_table :cloud_driver_workflow_actions do |t|
            table_base_structure.each do |column|
                t.send(
                    column["type"].parameterize.underscore.to_sym,
                    column["name"].parameterize.underscore.to_sym
                )
            end

            t.timestamps
        end
        
        add_reference   :cloud_driver_workflow_actions, :cloud_driver_workflows, foreign_key: true, index: { name: "driver_workflow_actions_workflows" }
        add_foreign_key :cloud_driver_workflow_actions, :cloud_driver_workflow_statuses, column: :initial_status_id
        add_foreign_key :cloud_driver_workflow_actions, :cloud_driver_workflow_statuses, column: :final_status_id
    end
end
