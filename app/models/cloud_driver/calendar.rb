=begin

Copyright (c) 2020, all rights reserved.

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
    class Calendar < CloudObject::Base
        belongs_to  :account,        foreign_key: "cloud_driver_accounts_id"
        belongs_to  :user_creator,   foreign_key: "users_id",        class_name: "::User", optional: true
        belongs_to  :user_main,      foreign_key: "user_main_id",   class_name: "::User", optional: true
        belongs_to  :status,         foreign_key: "cloud_driver_workflow_statuses_id", class_name: "Workflow::Status", optional: true

        has_one     :detail, foreign_key: "cloud_driver_calendars_id", dependent: :delete, inverse_of: :calendar, autosave: true
        accepts_nested_attributes_for :detail

        has_many :events, foreign_key: "cloud_driver_calendars_id"

        scope :default, -> { joins(:detail).where("cloud_driver_calendar_details.default = ?", true).select(:id, :name).first }



        enum types_module_events: {
            driver_events: "driver_events",
            focus_tasks: ('focus_tasks' if defined? CloudFocus),
            help_tickets: ('help_tickets' if defined? CloudHelp)
        }.compact


        def self.initialize_data(account)
            default_calendar = self.create!(
                account: account
            )
            Calendar::Detail.create!(
                name: "Default Calendar",
                default: true,
                cloud_driver_calendars_id: default_calendar.id
            )
        end

        def self.events_from_all_modules(current_user, query)
            LC::Debug.msg "Deprecated"
            self.index(current_user, query)
        end

        def self.index(current_user, query)

            LC::Debug.msg "ldonis"

            if query[:filters][:start_date].blank? or query[:filters][:end_date].blank?
                filters_date = self.get_date_range_filter()
                query[:filters][:start_date] = filters_date[:start_date]
                query[:filters][:end_date] = filters_date[:end_date]
            end

            calendar = self.default
            calendar_data = {
                id: calendar.id,
                name: calendar.name,
                driver_events: [],
                focus_tasks: [],
                help_tickets: []
            }

            # events from CloudDriver
            unless query[:filters][:include] && query[:filters][:include][:driver_events].to_s.downcase == "false"           

                # selection all my events in one query
                own_and_public_driver_events = calendar.events.joins(:detail)
                .joins("inner join cloud_driver_event_attendants CDEA on CDEA.cloud_driver_events_id = cloud_driver_events.id")
                .select(
                    :users_id,
                    :user_main_id,
                    :id, 
                    :title, 
                    :description, 
                    "event_date as date",
                    "time_start as start", 
                    "time_end as end", 
                    :location,
                    :model_type,
                    :url,
                    :event_type,
                    "true as \"is_attendant\"",
                    "false as \"editable\"",
                    "CONCAT('cloud_driver_event',' ', LOWER(SPLIT_PART(cloud_driver_events.model_type, '::', 2)))  as \"classNames\"",
                    LC::Date2.new.date_time.db_column("event_date")
                )
                .where("
                    CDEA.users_id = :user 
                    or cloud_driver_events.user_main_id = :user 
                    or cloud_driver_events.users_id = :user
                    or cloud_driver_event_details.public = true", { user: current_user.id })
                .where("cloud_driver_event_details.event_date >= ?", query[:filters][:start_date])
                .where("cloud_driver_event_details.event_date <= ? ", query[:filters][:end_date])
                .order("date")
        
                own_and_public_driver_events.each do |event|
                    event[:editable] = event.is_editable_by?(current_user)
                end

                calendar_data[:driver_events] = own_and_public_driver_events
            end

            # tasks from CloudFocus
            if query[:filters][:include] && query[:filters][:include][:focus_tasks].to_s.downcase == "true"
                calendar_data[:focus_tasks]  = Courier::Focus::Task.with_deadline(current_user, query).map do |task|
                    {
                        id: task[:id],
                        title: task[:title],
                        description: task[:description],
                        date: task[:deadline],
                        start: task[:deadline],
                        end: task[:deadline],
                        event_date_string: task[:deadline_string],
                        classNames: ["cloud_focus_tasks"]
                    }
                end
            end

            # tickets from CloudHelp
            if query[:filters][:include] && query[:filters][:include][:help_tickets].to_s.downcase == "true"
                calendar_data[:help_tickets]  = Courier::Help::Ticket.with_deadline(current_user, query).map do |ticket|
                    {
                        id: ticket[:id],
                        title: ticket[:subject],
                        description: ticket[:description],
                        date: ticket[:deadline],
                        start: ticket[:deadline],
                        end: ticket[:deadline],
                        event_date_string: ticket[:deadline_string],
                        classNames: ["cloud_help_tickets"]
                    }
                end
            end

            calendar_data
        end

        def self.get_date_range_filter(year=nil, month=nil, day=nil)
            start_date = Date.today
            start_date = Time.current.beginning_of_month
            start_date = start_date.change(:year => year.to_i) if !year.blank?
            start_date = start_date.change(:month => month.to_i) if !month.blank?
            start_date = start_date.change(:day => day.to_i) if !day.blank?

            end_date = Date.today
            end_date = Time.current
            end_date = end_date.change(:year => year.to_i) if !year.blank?
            end_date = end_date.change(:month => month.to_i) if !month.blank?
            end_date = end_date.end_of_month
            end_date = end_date.change(:day => day.to_i) if !day.blank?

            { start_date: start_date, end_date: end_date }
        end

        def self.options(current_user, query)
            {
                :types_module_events => Calendar.types_module_events
            }
        end
    end
end
