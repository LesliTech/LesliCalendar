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

class CreateLesliCalendarEvents < ActiveRecord::Migration[6.0]
    def change
        create_table :lesli_calendar_events do |t|
            t.string    :title, required: true
            t.string    :description
            t.datetime  :start_at, index: true
            t.datetime  :end_at, index: true
            t.string    :url
            t.string    :location
            t.string    :status, index: true # proposal, draft, approved
            t.boolean   :public, index: true

            t.datetime  :deleted_at, index: true
            t.timestamps
        end
        
        add_reference(:lesli_calendar_events, :account,  foreign_key: { to_table: :lesli_accounts })
        add_reference(:lesli_calendar_events, :calendar, foreign_key: { to_table: :lesli_calendar_calendars })
        add_reference(:lesli_calendar_events, :user,     foreign_key: { to_table: :lesli_users })

        #add_reference(:cloud_driver_events, :assign,   foreign_key: { to_table: :users })
        #add_reference(:cloud_driver_events, :type,     foreign_key: { to_table: :cloud_driver_catalog_event_types})
    end
end
