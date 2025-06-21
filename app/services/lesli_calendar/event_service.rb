=begin 

Lesli

Copyright (c) 2024, Lesli Technologies, S. A.

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
            #super(current_user.account.calendar.calendar.find_by(id: calendar_id))
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
                "'lesli-calendar' as classnames"
            )

            events_support = ::Lesli::Courier.new(:lesli_support, [])
            .from(:ticket_service, current_user, query)
            .call(:index_with_deadline)
            .map do |ticket|
                {
                    id: ticket.id,
                    title: ticket.subject,
                    deadline: ticket.deadline,
                    description: ticket.description,
                    date: ticket.deadline,
                    start: ticket.deadline,
                    classnames: 'lesli-support'
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
            # Get current date and time
            current_date = Time.now

            # Combine events and support events into one array
            merged_events = self.index

            # Filter out past events
            filtered_events = merged_events.select do |event|
                event[:start_at] >= current_date.beginning_of_day
            end

            # Group events by date
            grouped_events = filtered_events.each_with_object({}) do |event, acc|

                date_key = event[:start_at].strftime('%Y-%m-%d')

                unless acc.key?(date_key)
                    day_name = event[:start_at].to_date == current_date.to_date ? 'Today' : event[:start_at].strftime('%a')
                    day_number = event[:start_at].to_date == current_date.to_date ? event[:start_at].strftime('%H:%M') : event[:start_at].strftime('%d')

                    acc[date_key] = {
                        day_name: day_name,
                        day_number: day_number,
                        events: []
                    }
                end

                if event[:description]
                    # Remove HTML tags and truncate description
                    event[:description] = event[:description].gsub(/<[^>]*>?/, '')[0, 85] + '...'
                end

                # Add event to the array corresponding to its date
                acc[date_key][:events] << event
            end

            # Sort the groups by date
            sorted_grouped_events = grouped_events.sort.to_h

            # Assign to agenda
            sorted_grouped_events
        end 
    end
end
