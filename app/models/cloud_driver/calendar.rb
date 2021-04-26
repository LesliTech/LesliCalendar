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
            focus_tasks: "focus_tasks",
            help_tickets: "help_tickets"
        }


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

        def self.index(current_user, query)
            if query[:filters][:start_date].blank? or query[:filters][:end_date].blank?
                filters_date = self.get_date_range_filter()
                query[:filters][:start_date] = filters_date[:start_date]
                query[:filters][:end_date] = filters_date[:end_date]
            end

            calendar = self.default

            Courier::Driver::Calendar.index(current_user, query, calendar)
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
                types_module_events: Calendar.types_module_events
            }
        end
    end
end
