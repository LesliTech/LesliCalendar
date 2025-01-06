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


# · 
require "json"

# · 
file = File.open(LesliCalendar::Engine.root.join("db", "seed", "seeds.json")).read
seeds = JSON.parse(file)

# · 
current_user = ::Lesli::User.first
calendar = LesliCalendar::CalendarService.new(current_user).find_default.result

LesliCalendar::EventService.new(current_user).create({
    title: "test",
    description: "test",
    start_at: "2025-01-05",
    end_at: "2025-01-06",
    url: "https://lesli.dev",
    location: "Guatemala",
    status: "draft",
    public: true,
})

# · 
seeds["events"].each_with_index do |event, index|

    # Start events from 10 days ago
    event_date = (index - 10).days.from_now 

    #
    LesliCalendar::EventService.new(current_user).create({
        title: event["title"],
        description: event["description"],
        start_at: event_date,
        end_at: event_date,
        url: "",
        location: event["location"],
        status: "",
        public: true,
    })
end

