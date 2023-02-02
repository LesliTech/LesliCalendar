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

class CloudDriver::CalendarService < LesliService
    # Find an specific resource through the main id
    def find id
        # Look for the resource in the database
        # Filtering the calendars by the current user calendars and the public calendars
        calendars = current_user.account.driver.calendars.where(
            user_main: current_user
        ).or(
            current_user.account.driver.calendars.where(user_main: nil)
        )

        # Getting the calendar
        self.resource = calendars.find_by_id(id)

        # Should always return self
        self
    end


    # Find an specific resource through the main id
    def find_by_source source_code, default: false
        # Look for the resource in the database
        calendar = current_user.account.driver.calendars.find_by(
            user_main: current_user,
            user_creator: current_user,
            source_code: source_code,
            default: default
        )

        # Getting the calendar
        self.resource = calendar

        # Should always return self
        self
    end


    # Set the default calendar as resource
    def default_calendar
        # The account shared calendar
        self.resource = current_user.account.driver.calendars.find_by(default: true, user_main_id: nil, users_id: nil)

        self
    end


    # Standard method to index data from the database
    def index query
        # Parsing filters
        filters = query[:filters]

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
                search_string: "%#{LC::Sql.sanitize_for_search(search_string)}%"
            )
        end

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
        return records
        .page(query[:pagination][:page])
        .per(query[:pagination][:perPage])
        .order("#{query[:order][:by]} #{query[:order][:dir]} NULLS LAST")
    end


    # Standard method to show data from the database
    def show query
        return {} unless self.found?

        # Calendar data
        calendar_data = {
            id: self.resource.id,
            name: self.resource.name,
            users_id: self.resource.user_main_id,
            user_name: self.resource.user_main_id ? self.resource.user_main.full_name : nil,
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
        calendar_events = Courier::Driver::Event.with_deadline(current_user, query, self.resource)
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

        return calendar_data
    end


    # Standard method to create new resource into the database
    def create params
        calendar = current_user.account.driver.calendars.create_with(
            name: params[:name],
            default: params[:default] || false,
        ).find_or_initialize_by(
            user_main: current_user,
            user_creator: current_user,
            source_code: params[:source_code] || "lesli",
        )

        if calendar.save
            self.resource = calendar
        else
            self.error(calendar.errors.full_messages.to_sentence)
        end

        self
    end
end
