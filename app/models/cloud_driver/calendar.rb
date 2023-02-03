=begin

Copyright (c) 2023, all rights reserved.

All the information provided by this platform is protected by international laws related  to
industrial property, intellectual property, copyright and relative international laws.
All intellectual or industrial property rights of the code, texts, trade mark, design,
pictures and any other information belongs to the owner of this platform.

Without the written permission of the owner, any replication, modification,
transmission, publication is strictly forbidden.

For more information read the license file including with this software.

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// ·

=end
module CloudDriver
    class Calendar < CloudObject
        belongs_to  :account,        foreign_key: "cloud_driver_accounts_id"
        belongs_to  :user_creator,   foreign_key: "users_id",        class_name: "::User", optional: true
        belongs_to  :user_main,      foreign_key: "user_main_id",    class_name: "::User", optional: true
        belongs_to  :status,         foreign_key: "cloud_driver_workflow_statuses_id", class_name: "Workflow::Status", optional: true

        # Needs to be implemented in order to be able to run migration: 0301100219_drop_cloud_driver_calendar_details.rb
        has_one     :detail, foreign_key: "cloud_driver_calendars_id"

        has_many :events, foreign_key: "cloud_driver_calendars_id"

        # @return [CloudDriver::Calendar] The account shared calendar
        def self.default(current_user)
            LC::Debug.deprecation("CloudDriver::Calendar.default(current_user) is deprecated. User CloudDriver::CalendarService instead.")
            current_user.account.driver.calendars.find_by(default: true, user_main_id: nil, users_id: nil)
        end

        # @return [void]
        # @param account [CloudDriver::Account] The account to be initialized
        # @description Initializes the data required for the calendars to work when a new account is created.
        #     @example
        #         new_account = Account.create!({}) # This method should initialize a new CloudDriver::Account
        #         # The instance of CloudDriver::Account should call this method in an after_create()
        def self.initialize_data(account)
            account.calendars.create_with(
                name: "Default Calendar",
                default: true,
            ).find_or_create_by!(
                account: account
            )
        end

        # @return [Hash] The required information to create or filter a calendar
        # @param current_user [User] The user that requested this method to be executed. Unused at the moment
        # @param query [Hash] Hash containing important information to filter these options. Unused at the moment
        # @description Retrueves and returns a hash on information required to create or filter a calendar.
        #     At the moment, only event_categories are returned.
        # @example
        #     puts CloudDriver::Calendar.options(User.find(2), {})
        #     # This will display something like
        #     # {
        #     #     event_categories: {
        #     #         all: "all",
        #     #         driver_events: "driver_events",
        #     #         focus_tasks: "focus_tasks",
        #     #         help_tickets: "help_tickets"
        #     #     }
        #     # }
        def self.options(current_user, query)
            {
                event_categories: Calendar.event_categories
            }
        end

        def self.sync(current_user)
            Courier::One::IntegrationEventsService.google_sync(current_user)
        end

        protected

        # @return [Hash] A hash containing a list of event categories
        # @description Returns a list of event categories. An event category is a class that represents a cloud_object
        #     that can be added to a calendar as an event. Current event categories are all, driver_events, focus_tasks
        #     and help_tickets
        # @example
        #     puts CloudDriver::Calendar.event_categories
        #     # This will display something like
        #     # {
        #     #     all: "all",
        #     #     driver_events: "driver_events",
        #     #     focus_tasks: "focus_tasks",
        #     #     help_tickets: "help_tickets"
        #     # }
        def self.event_categories
            {
                all: "all",
                driver_events: "driver_events",
                focus_tasks: "focus_tasks",
                help_tickets: "help_tickets",
            }
        end


        def self.filter_records_by_text(records, search_text, fields: ["title", "description"])

            if search_text
                search_text.each do |query_word|
                    sql = []
                    fields.each do |field|
                        sql.push("lower(#{field}) like '%#{query_word}%'")
                    end

                    records = records.where(sql.join(" or "))
                end
            end

            return records
        end

    end
end
