class AlterCloudDriverAccounts < ActiveRecord::Migration[6.0]
    def change
        add_column :cloud_driver_accounts, :created_at, :datetime, null: false, default: -> { "NOW()" }
        add_column :cloud_driver_accounts, :updated_at, :datetime, null: false, default: -> { "NOW()" }
    end
end
