class CreateCloudDriverWorkflowAssociations < ActiveRecord::Migration[6.0]
    def change
        table_base_structure = JSON.parse(File.read(Rails.root.join("db","structure","00000203_workflow_associations.json")))
        create_table :cloud_driver_workflow_associations do |t|
            table_base_structure.each do |column|
                t.send(
                    column["type"].parameterize.underscore.to_sym,
                    column["name"].parameterize.underscore.to_sym
                )
            end

            # Specific fields to which you can associate a workflow with
            t.bigint :project_type

            # acts_as_paranoid
            t.datetime :deleted_at, index: true

            t.timestamps
        end

        add_reference :cloud_driver_workflow_associations, :cloud_driver_workflows, foreign_key: true, index: { name: "driver_workflow_associations_workflows" }
    end
end
