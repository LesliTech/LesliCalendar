module CloudDriver
    class ApplicationController < ApplicationLesliController
        protect_from_forgery with: :exception

        before_action :check_account
        before_action :check_calendar_default

        def check_account
            if current_user.account.driver.blank?
                current_user.account.driver = CloudDriver::Account.new
                current_user.account.driver.account = current_user.account
                current_user.account.driver.save!
            end
        end

        def check_calendar_default
            if current_user.account.driver.calendars.default.blank?
                current_user.account.driver.calendars.create({
                    detail_attributes: {
                        name: @account[:user][:name],
                        default: true
                    }
                })
            end
        end

    end
end
