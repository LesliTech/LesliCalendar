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
            events = current_user.account.calendar.calendars.first.events
            .select(
                :id, 
                :title, 
                :description, 
                :date, 
                :start, 
                :end, 
                :url, 
                :location, 
                :status, 
                "'lesli-calendar' as classnames"
            )
        end

        def create(event_params)

            # Setting the default calendar if not provided
            calendar = CalendarService.new(current_user).find_default.result

            # Creating the event
            event = calendar.events.new(event_params)
            event.account = calendar.account
            event.user = current_user

            if event.save
                #Event.log_activity_create(current_user, event)
                # Adding the main user as an attendant too
                #event.attendants.create(users_id: event.user_main.id)
                self.resource = event
            end
            self
        end
    end
end
