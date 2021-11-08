class CreateCloudDriverCatalogEventTypes < ActiveRecord::Migration[6.1]
    def change
        create_table :cloud_driver_catalog_event_types do |t|
            t.string :name
            t.string :model_type, index: true

            # acts_as_paranoid
            t.datetime :deleted_at, index: true

            t.timestamps
        end

        add_reference :cloud_driver_catalog_event_types, :cloud_driver_accounts, foreign_key: true, index: { name: "driver_catalog_event_types_accounts" }
    end
end
