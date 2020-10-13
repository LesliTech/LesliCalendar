module CloudDriver
    class Account < ApplicationRecord
        belongs_to :account, class_name: "::Account", foreign_key: "id"

        has_many :calendars, foreign_key: "cloud_driver_accounts_id"
        has_many :events, foreign_key: "cloud_driver_accounts_id"
        
        after_create :initialize_account

        # @return [void]
        # @description Initializes all required information for this account to work properly
        # @example
        #     house_account = CloudHouse::Account.new(::Account.find(1))
        # Rails will automatically execute this method after the account is created
        def initialize_account
            Workflow.initialize_data(self)
            Dashboard.initialize_data(self)
        end
    end
end
