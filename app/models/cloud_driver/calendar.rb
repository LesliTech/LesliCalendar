=begin

Copyright (c) 2022, all rights reserved.

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

        has_one     :detail, foreign_key: "cloud_driver_calendars_id", dependent: :delete, inverse_of: :calendar, autosave: true
        accepts_nested_attributes_for :detail

        has_many :events, foreign_key: "cloud_driver_calendars_id"

        scope :default, -> { joins(:detail).where(cloud_driver_calendar_details: { default: true }, users_id: nil, user_main_id: nil).select(:id, :name, :source_code).first }

        # @return [Array] Array of calendars of the current_user
        def self.index(current_user, query)
            # Parsing filters
            filters = query[:filters]

            # Get order params from query
            unless query.dig(:order, :by).blank?
                order_by = query.dig(:order, :by)
                order_dir = query.dig(:order, :dir)
            end

            # get search string from query params
            search_string = query[:search].downcase.gsub(" ","%") unless query[:search].blank?

            # Executing the query
            records = current_user.account.driver.calendars

            # Joining calendar with details
            records = records.joins(:detail)

            # Filtering by the calendars of the current_user
            records = records.where(user_main_id: current_user.id)

            # We filter by a text string written by the user
            unless search_string.blank?
                records = records.where(
                    "
                    (LOWER(source_code) SIMILAR TO :search_string) OR
                    (LOWER(cloud_driver_calendar_details.name) SIMILAR TO :search_string)
                    ",
                    search_string: "%#{sanitize_sql_like(search_string, " ")}%"
                )
            end

            # Adding order to the query
            records = records.order(order_by.concat(" ").concat(order_dir)) unless order_by.blank?

            # Formating the response
            records = records.select(
                'cloud_driver_calendars.id',
                'cloud_driver_calendar_details.name',
                'cloud_driver_calendar_details.default',
                'cloud_driver_calendars.created_at',
                'cloud_driver_calendars.updated_at',
                'cloud_driver_calendars.source_code',
                'cloud_driver_calendars.user_main_id',
                LC::Date2.new.db_column("created_at", "cloud_driver_calendars"),
                LC::Date2.new.db_column("updated_at", "cloud_driver_calendars"),
            )

            # Adding pagination
            records.page(query[:pagination][:page]).per(query[:pagination][:perPage])
        end

        # @return [void]
        # @param account [CloudDriver::Account] The account to be initialized
        # @description Initializes the data required for the calendars to work when a new account is created.
        #     @example
        #         new_account = Account.create!({}) # This method should initialize a new CloudDriver::Account
        #         # The instance of CloudDriver::Account should call this method in an after_create()
        def self.initialize_data(account)
            account.calendars.create_with(
                detail_attributes: {
                    name: "Default Calendar",
                    default: true,
                }
            ).find_or_create_by!(
                account: account
            )
        end

        # @return [Array] Array of CloudObjects that can be ordered within a calendar as events or an empty array if
        #     query[:filters][:start_date] and query[:filters][:end_date] are not set.
        # @param current_user [User] The user that requested this method to be executed
        # @param query [Hash] Hash containing important information like wether to include help_tickets and focus_tasks,
        #     and start_date and end_date
        # @description Retrieves a list of cloud_objects that can be arranged into a calendar. At the time, driver_events,
        #     focus_tasks and help_tickets are the only cloud_objects included. Uses the courier to retrieve this information.
        # @example
        #     current_user = User.find(1)
        #     query = {
        #         filters: {
        #             start_date: "2020-01-01 00:00",
        #             end_date: "2020-01-20 00:00",
        #             include: {
        #                 driver_events: "true",
        #                 focus_tasks: "false",
        #                 help_tickets: "true"
        #             }
        #         }
        #     }
        #     puts CloudDriver::Calendar.index(current_user, query)
        #     # this will display something like
        #     # {
        #         help_tickets: [...],
        #         driver_events: [...],
        #     }
        def self.show(current_user, query)
            if query[:filters][:start_date].blank? or query[:filters][:end_date].blank?
                return {
                    id: self.default.id,
                    name: self.default.name,
                    driver_events: [],
                    focus_tasks: [],
                    help_tickets: [],
                }
            end

            calendar = current_user.account.driver.calendars.default
            Courier::Driver::Calendar.show(current_user, query, calendar)
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

    end
end
