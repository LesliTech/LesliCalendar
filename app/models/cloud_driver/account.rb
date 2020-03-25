module CloudDriver
    class Account < ApplicationRecord
        belongs_to :account, class_name: "::Account", foreign_key: "id"

        has_many :calendars, foreign_key: "cloud_driver_accounts_id"
        has_many :events, foreign_key: "cloud_driver_accounts_id"
        
        after_create :check_account

        def check_account

        end

    end
end
