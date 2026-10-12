=begin 

Lesli

Copyright (c) 2025, Lesli Technologies, S. A.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see http://www.gnu.org/licenses/.

Lesli · Ruby on Rails SaaS Development Framework.

Made with ♥ by LesliTech
Building a better future, one line of code at a time.

@contact  hello@lesli.tech
@website  https://www.lesli.tech
@license  GPLv3 http://www.gnu.org/licenses/gpl-3.0.en.html

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 
=end

module LesliCalendar
    class EventService < Lesli::ApplicationLesliService

        def find calendar_id
            super(current_user.account.calendar.calendars.first)
        end

        def index()
            events_calendar = current_user.account.calendar.calendars.first.events
            .select(
                :id, 
                :title, 
                :description, 
                :start_at, 
                :end_at, 
                :url, 
                :location, 
                :status, 
                :public,
                "'lesli-calendar' as classnames"
            ).map do |event|
                {
                    id: event.id,
                    title: event.title,
                    start: event.start_at.present? ? event.start_at : nil, 
                    end: event.end_at.present? ? event[:end_at].iso8601 : nil, 
                    url: event.url, 
                    classNames: event.classnames,
                    extendedProps: {
                        description: event.description,
                        location: event.location,
                        status: event.status,
                        public: event.public
                    }
                }
            end

            events_support = ::Lesli::Courier.new(:lesli_support, [])
            .from(:ticket_service, current_user, query)
            .call(:index_with_deadline)
            .map do |ticket|
                {
                    id: ticket.id,
                    title: ticket.subject,
                    start: ticket.deadline,
                    end: ticket.deadline,
                    classNames: 'lesli-support',
                    extendedProps: {
                        description: ticket.description,
                        public: true,
                    }
                }
            end

            events_calendar + events_support
        end

        def create(event_params)

            # Setting the default calendar if not provided
            calendar = CalendarService.new(current_user).find_default.result

            # Creating the event
            event = calendar.events.new(event_params)
            
            event.user = current_user
            event.account = current_user.account.calendar

            if event.save
                #Event.log_activity_create(current_user, event)
                # Adding the main user as an attendant too
                #event.attendants.create(users_id: event.user_main.id)
                self.resource = event
            end
            self
        end

        def show (id)
            event = current_user.account.calendar.events.find_by_id(id)
            self.resource = event
            self
        end

        def agenda
            current_time = Time.current

            # Convert FullCalendar's payload into the simpler shape consumed by the agenda view.
            upcoming_events = index.filter_map do |event|
                start_at = normalize_agenda_time(value_from(event, :start))
                next if start_at.nil? || start_at < current_time.beginning_of_day

                extended_props = value_from(event, :extendedProps) || {}

                {
                    id: value_from(event, :id),
                    title: value_from(event, :title),
                    description: agenda_description(value_from(extended_props, :description)),
                    start_at: start_at,
                    end_at: normalize_agenda_time(value_from(event, :end)),
                    url: value_from(event, :url),
                    classnames: Array(value_from(event, :classNames)).join(" ")
                }
            end

            # Sorting first preserves chronological order for both days and their events.
            upcoming_events.sort_by { |event| event[:start_at] }.each_with_object({}) do |event, agenda|
                start_at = event[:start_at]
                date_key = start_at.to_date.iso8601
                today = start_at.to_date == current_time.to_date

                agenda[date_key] ||= {
                    day_name: today ? "Today" : start_at.strftime("%a"),
                    day_number: today ? start_at.strftime("%H:%M") : start_at.strftime("%d"),
                    events: []
                }

                agenda[date_key][:events] << event
            end
        end

        private

        def value_from(hash, key)
            return unless hash.respond_to?(:[])

            hash[key] || hash[key.to_s]
        end

        # FullCalendar sources may provide dates as Rails objects or ISO 8601 strings.
        def normalize_agenda_time(value)
            case value
            when ActiveSupport::TimeWithZone
                value
            when Time, DateTime, Date
                value.in_time_zone
            when String
                Time.zone.parse(value)
            end
        rescue ArgumentError, TypeError
            nil
        end

        def agenda_description(description)
            return if description.blank?

            text = ActionController::Base.helpers.strip_tags(description.to_s).squish
            ActionController::Base.helpers.truncate(text, length: 88)
        end
    end
end
