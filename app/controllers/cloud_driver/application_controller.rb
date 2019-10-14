module CloudDriver
    class ApplicationController < ApplicationLesliController
        protect_from_forgery with: :exception

        before_action :check_account

        def check_account

            if current_user.account.driver.blank?

                # insert reference to the core account
                current_user.account.driver = CloudDriver::Account.new
                current_user.account.driver.account = current_user.account
                current_user.account.driver.save!

            end

        end

    end
end
