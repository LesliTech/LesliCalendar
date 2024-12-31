=begin

Lesli

Copyright (c) 2023, Lesli Technologies, S. A.

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

Made with ♥ by https://www.lesli.tech
Building a better future, one line of code at a time.

@contact  hello@lesli.tech
@website  https://www.lesli.tech
@license  GPLv3 http://www.gnu.org/licenses/gpl-3.0.en.html

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 
=end

module LesliCalendar
    class CalendarService < Lesli::ApplicationLesliService

        def find calendar_id
            #super(current_user.account.calendar.calendar.find_by(id: calendar_id))
            super(current_user.account.calendar.calendars.first)
        end

        def find_default
            find(current_user.account.calendar.calendars.find_by(:name => "default"))
            current_user.account.calendar.calendars.first
        end

        def show()

            # Calendar data
            calendar_data = {
                id: self.resource.id,
                name: self.resource.name,
                user_id: self.resource.user_id,
                events: EventService.new(current_user, query).index(),
                events_support: ::Lesli::Courier.new(:lesli_support, [])
                .from(:ticket_service)
                .with(current_user, query)
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
            }
        end
    end
end
