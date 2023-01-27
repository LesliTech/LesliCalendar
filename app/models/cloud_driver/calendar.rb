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

        has_many :events, foreign_key: "cloud_driver_calendars_id"

        # @return [CloudDriver::Calendar] The account shared calendar
        def self.default(current_user)
            current_user.account.driver.calendars.find_by(default: true, user_main_id: nil, users_id: nil)
        end

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

            # Filtering by the calendars of the current_user and the shared calendars
            records = records.where(
                user_main: current_user
            ).or(
                records.where(user_main: nil)
            )

            # We filter by a text string written by the user
            unless search_string.blank?
                records = records.where(
                    "
                    (LOWER(source_code) SIMILAR TO :search_string) OR
                    (LOWER(name) SIMILAR TO :search_string)
                    ",
                    search_string: "%#{sanitize_sql_like(search_string, " ")}%"
                )
            end

            # Adding order to the query
            records = records.order(order_by.concat(" ").concat(order_dir)) unless order_by.blank?

            # Formating the response
            records = records.select(
                :id,
                :name,
                :default,
                :created_at,
                :updated_at,
                :source_code,
                :user_main_id,
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
                name: "Default Calendar",
                default: true,
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
        def show(current_user, query)
            # Calendar data
            calendar_data = {
                id: self.id,
                name: self.name,
                users_id: self.user_main_id,
                user_name: self.user_main_id ? self.user_main.full_name : nil,
                events: [],
                driver_events: [],
                focus_tasks: [],
                help_tickets: [],
            }

            # If filter dates not provided, force use current month
            if query[:filters][:start_date].blank? or query[:filters][:end_date].blank?
                query[:filters][:start_date] = query[:filters][:start_date] || Time.now.beginning_of_month.to_s
                query[:filters][:end_date] = query[:filters][:end_date] || Time.parse(query[:filters][:start_date]).end_of_month.to_s
            end

            search_text = nil

            # Setting search text
            if (query[:filters][:search]) && (! query[:filters][:search].empty?)
                search_text = query[:filters][:search].downcase.split(" ")
            end

            # Getting calendar events
            calendar_events = Courier::Driver::Event.with_deadline(current_user, query, self)
            calendar_events = CloudDriver::Calendar.filter_records_by_text(calendar_events, search_text, fields: ["title", "description", "location"])
            calendar_data[:events] = calendar_events

            # Events from CloudDriver
            # This condition is diferent because, by default, driver events are included
            unless query[:filters][:include] && query[:filters][:include][:driver_events].to_s.downcase == "false"
                driver_events = calendar_events.map do |event|
                    {
                        id: event[:id],
                        title: event[:title],
                        description: event[:description],
                        date: event[:date],
                        start: event[:start],
                        end: event[:end],
                        is_attendant: event[:is_attendant],
                        event_type: event[:event_type],
                        classNames: ["cloud_driver_events"],
                    }
                end

                calendar_data[:driver_events] = driver_events
            end

            # Tasks from CloudFocus
            if query[:filters][:include] && query[:filters][:include][:focus_tasks].to_s.downcase == "true"
                focus_tasks  = Courier::Focus::Task.with_deadline(current_user, query)
                focus_tasks = CloudDriver::Calendar.filter_records_by_text(focus_tasks, search_text)

                focus_tasks = focus_tasks.map do |task|
                    {
                        id: task[:id],
                        title: task[:title],
                        description: task[:description],
                        date: task[:deadline],
                        start: task[:deadline],
                        end: task[:deadline] ? task[:deadline] + 1.second : nil, # The calendar will crash if start and end dates are the same
                        classNames: ["cloud_focus_tasks"]
                    }
                end

                calendar_data[:focus_tasks] = focus_tasks
            end

            # Tickets from CloudHelp
            if query[:filters][:include] && query[:filters][:include][:help_tickets].to_s.downcase == "true"
                help_tickets  = Courier::Help::Ticket.with_deadline(current_user, query)
                help_tickets = CloudDriver::Calendar.filter_records_by_text(help_tickets, search_text, fields: ["subject", "description"])

                help_tickets = help_tickets.map do |ticket|
                    {
                        id: ticket[:id],
                        title: ticket[:subject],
                        description: ticket[:description],
                        date: ticket[:deadline],
                        start: ticket[:deadline],
                        end: ticket[:deadline] ? ticket[:deadline] + 1.second : nil, # The calendar will crash if start and end dates are the same
                        classNames: ["cloud_help_tickets"]
                    }
                end

                calendar_data[:help_tickets] = help_tickets
            end

            calendar_data
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
