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
    class Calendar < ApplicationRecord

        belongs_to :account, foreign_key: "cloud_driver_accounts_id"

        has_one :detail, foreign_key: "cloud_driver_calendars_id", dependent: :delete, inverse_of: :calendar, autosave: true
        accepts_nested_attributes_for :detail

        has_many :events, foreign_key: "cloud_driver_calendars_id"

        scope :default, -> { joins(:detail).where("cloud_driver_calendar_details.default = ?", true).select(:id, :name).first }

        def self.events_from_all_modules(current_user, query)

            calendar = self.default
            today = Time.now.strftime("%Y%m%d")

            # tasks from CloudFocus
            focus_tasks = Courier::Focus::Task.with_deadline(current_user, query).map do |task|
                {
                    id: task[:id],
                    title: task[:title],
                    description: task[:description],
                    start: task[:deadline],
                    end: task[:deadline],
                    classNames: ["cloud_focus_task"]
                }
            end

            # tasks from CloudFocus
            help_tickets = Courier::Help::Ticket.with_deadline(current_user)

            # tasks from default calendar
            driver_events = calendar.events.joins(:detail)
            .where("cloud_driver_event_details.time_start = '#{today}'")
            .select(
                :id, 
                :title, 
                :description, 
                "time_start as start", 
                "time_end as end", 
                :location, 
                :url,
                "'cloud_driver_event' as \"classNames\""
            )

            {
                id: calendar.id,
                name: calendar.name,
                driver_events: driver_events,
                help_tickets: help_tickets,
                focus_tasks: focus_tasks
            }
        end

=begin
        def self.events_from_all_modules(current_user)

            calendar = self.default

            # tasks from CloudFocus
            focus_tasks = Courier::Focus::Task.with_deadline(current_user).map do |task|
                {
                    id: task[:id],
                    title: task[:title],
                    description: task[:description],
                    start: task[:deadline],
                    end: task[:deadline],
                    classNames: ["cloud_focus_task"]
                }
            end

            # tasks from CloudFocus
            help_tickets = Courier::Help::Ticket.with_deadline(current_user)

            # tasks from default calendar
            driver_events = calendar.events.joins(:detail)
            .select(
                :id, 
                :title, 
                :description, 
                "time_start as start", 
                "time_end as end", 
                :location, 
                :url,
                "'cloud_driver_event' as \"classNames\""
            )

            {
                id: calendar.id,
                name: calendar.name,
                driver_events: driver_events,
                help_tickets: help_tickets,
                focus_tasks: focus_tasks
            }
        end
=end

    end
end
