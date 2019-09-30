class CreateCloudDriverAccounts < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_driver_accounts do |t|
        end
        add_foreign_key :cloud_driver_accounts, :accounts, column: :id
    end
end
