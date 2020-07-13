=begin

Lesli

Copyright (c) 2020, Lesli Technologies, S. A.

All the information provided by this website is protected by laws of Guatemala related 
to industrial property, intellectual property, copyright and relative international laws. 
Lesli Technologies, S. A. is the exclusive owner of all intellectual or industrial property
rights of the code, texts, trade mark, design, pictures and any other information.
Without the written permission of Lesli Technologies, S. A., any replication, modification,
transmission, publication is strictly forbidden.
For more information read the license file including with this software.

Lesli - Your Smart Business Assistant

Powered by https://www.lesli.tech
Building a better future, one line of code at a time.

@license  Propietary - all rights reserved.
@version  0.1.0-alpha

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

        def self.events_from_all_modules(current_user, query)
            calendar = self.default
            calendar_data = {
                id: calendar.id,
                name: calendar.name,
                driver_events: [],
                focus_tasks: [],
                help_tickets: []
            }

            # events from CloudDriver
            all_events = {}

            # selection all my events in one query
            own_driver_events = calendar.events.joins(:detail)
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
                "CONCAT('cloud_driver_event',' ', LOWER(SPLIT_PART(cloud_driver_events.model_type, '::', 2)))  as \"classNames\""
            )
            .where("CDEA.users_id = ? or cloud_driver_events.user_main_id = ? or cloud_driver_events.users_id = ?", current_user.id, current_user.id, current_user.id)
            .where("cloud_driver_event_details.event_date >= ? and cloud_driver_event_details.event_date <= ?", query[:filters][:start], query[:filters][:end])
            own_driver_events.each do |event|
                event[:editable] = event.is_editable_by?(current_user)
                all_events[event.id] = event
            end

            # selection all other public events in another query
            public_driver_events = calendar.events.joins(:detail)
            .select(
                :id,
                :users_id,
                :user_main_id,
                :title, 
                :description, 
                "event_date as date",
                "time_start as start", 
                "time_end as end", 
                :location,
                :model_type,
                :url,
                :event_type,
                "false as \"is_attendant\"",
                "false as \"editable\"",
                "CONCAT('cloud_driver_event',' ', LOWER(SPLIT_PART(cloud_driver_events.model_type, '::', 2)))  as \"classNames\""
            )
            .where("cloud_driver_event_details.public = true")
            .where("cloud_driver_event_details.event_date >= ? and cloud_driver_event_details.event_date <= ?", query[:filters][:start], query[:filters][:end])
            public_driver_events.each do |event|
                unless all_events[event.id]
                    event[:editable] = event.is_editable_by?(current_user)
                    all_events[event.id] = event
                end
            end

            calendar_data[:driver_events] = all_events.values.sort_by(&:date)
            
            # tasks from CloudFocus
            if query[:filters][:include] && query[:filters][:include][:focus_tasks]
                calendar_data[:driver_events]  = Courier::Focus::Task.with_deadline(current_user, query).map do |task|
                    {
                        id: task[:id],
                        title: task[:title],
                        description: task[:description],
                        date: task[:deadline],
                        start: task[:deadline],
                        end: task[:deadline],
                        classNames: ["cloud_driver_event"]
                    }
                end
            end

            # tickets from CloudHelp
            if query[:filters][:include] && query[:filters][:include][:help_tickets]
                calendar_data[:help_tickets]  = Courier::Help::Ticket.with_deadline(current_user)
            end

            calendar_data
        end

    end
end
