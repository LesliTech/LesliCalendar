=begin

Lesli

Copyright (c) 2026, Lesli Technologies, S. A.

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


# ·
require "json"

# ·
seed_file = LesliCalendar::Engine.root.join("db", "seed", "seeds.json")
event_seeds = JSON.parse(File.read(seed_file)).fetch("events")

current_user = ::Lesli::User.first
reference_time = Time.current
date_range_start = reference_time - 1.month - 15.days
date_range_end = reference_time + 1.month + 15.days
current_month_start = reference_time.beginning_of_month
current_month_end = reference_time.end_of_month

# Keep most demo records in the current month while preserving data on both sides of it.
current_month_count = (event_seeds.length * 0.6).round
outside_month_count = event_seeds.length - current_month_count
past_count = outside_month_count / 2

date_ranges = [
    *Array.new(past_count, date_range_start..(current_month_start - 1.second)),
    *Array.new(current_month_count, current_month_start..current_month_end),
    *Array.new(outside_month_count - past_count, (current_month_end + 1.second)..date_range_end)
].shuffle

# Pick a random second inside the assigned period.
random_time_in = ->(range) do
    range.begin + rand(0..(range.end - range.begin).to_i).seconds
end

event_seeds.zip(date_ranges).each do |event, date_range|
    start_at = random_time_in.call(date_range)

    LesliCalendar::EventService.new(current_user).create({
        title: event["title"],
        description: event["description"],
        start_at: start_at,
        end_at: start_at + 1.hour,
        url: "",
        location: event["location"],
        status: "approved",
        public: true
    })
end
