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

require "json"

examples = JSON.parse(File.read(LesliCalendar::Engine.root.join("db/seed/seeds.json"))).fetch("events")
now = Time.current.utc.change(usec: 0)
month = now.beginning_of_month

LesliCalendar::Account.includes(:account).find_each do |workspace|
    account = workspace.account
    users = account.users.order(:id).limit(2).to_a
    next if users.empty?

    owner, colleague = users
    scenarios = [
        { title: "Personal focus time", start_at: now + 2.hours },
        { title: "In progress", start_at: now - 30.minutes, end_at: now + 30.minutes },
        { title: "Completed meeting", start_at: now - 2.days },
        { title: "Overnight work", start_at: now.beginning_of_day - 2.hours, end_at: now + 1.hour },
        { title: "Month boundary", start_at: month - 2.hours, end_at: month + 2.hours },
        { title: "Next month planning", start_at: month.next_month + 10.days },
        { title: "UTC date boundary", start_at: now.tomorrow.beginning_of_day + 30.minutes },
        { title: "Cancelled public meeting", public: true, cancel: true },
        { title: "Cancelled meeting", cancel: true },
        { title: "Public meeting by organizer", public: true }
    ]

    if colleague
        scenarios += [
            { title: "Private invitation pending", organizer: colleague, user_ids: [owner.id] },
            { title: "Private invitation accepted", organizer: colleague, user_ids: [owner.id], response: :accepted },
            { title: "Private invitation declined", organizer: colleague, user_ids: [owner.id], response: :declined },
            { title: "Public event available", organizer: colleague, public: true },
            { title: "Public event accepted", organizer: colleague, public: true, response: :accepted },
            { title: "Public event declined", organizer: colleague, public: true, response: :declined },
            { title: "Private event without access", organizer: colleague },
            { title: "Rescheduled invitation", organizer: colleague, user_ids: [owner.id], response: :accepted, reschedule: true },
            { title: "Cancelled accepted invitation", organizer: colleague, user_ids: [owner.id], response: :accepted, cancel: true },
            { title: "Public invitation pending", organizer: colleague, public: true, user_ids: [owner.id] }
        ]
        if defined?(LesliShield) && (role = owner.roles.where(account_id: account.id).first)
            scenarios += [
                { title: "Role invitation pending", organizer: colleague, role_ids: [role.id] },
                { title: "Role invitation accepted", organizer: colleague, role_ids: [role.id], response: :accepted },
                { title: "Role invitation declined", organizer: colleague, role_ids: [role.id], response: :declined },
                { title: "Public role invitation", organizer: colleague, public: true, role_ids: [role.id] },
                { title: "Combined invitation accepted", organizer: colleague, role_ids: [role.id], user_ids: [owner.id], response: :accepted },
                { title: "Combined invitation", organizer: colleague, role_ids: [role.id], user_ids: [owner.id] }
            ]
        end
    end

    # Keep the original examples, distributed predictably across neighboring months.
    examples.each_with_index do |example, index|
        offset = index % 5 == 0 ? -1 : (index % 5 == 1 ? 1 : 0)
        scenarios << example.symbolize_keys.merge(start_at: month.advance(months: offset) + (index % 27).days + 10.hours)
    end

    scenarios.each do |scenario|
        title = "Demo: #{scenario.fetch(:title)}"
        # Repeated seeding preserves edited and soft-deleted demo events.
        next if account.calendar.events.with_deleted.exists?(title: title)

        organizer = scenario[:organizer] || owner
        start_at = scenario[:start_at] || now + 1.day
        LesliCalendar::Event.transaction do
            service = LesliCalendar::EventService.new(organizer).create(
                title: title, description: scenario[:description] || "Calendar demo: #{scenario[:title]}.",
                location: scenario[:location] || "Demo meeting room",
                start_at: start_at, end_at: scenario[:end_at] || start_at + 1.hour,
                public: scenario.fetch(:public, false),
                user_ids: scenario.fetch(:user_ids, []), role_ids: scenario.fetch(:role_ids, [])
            )
            raise ActiveRecord::RecordInvalid.new(service.result) unless service.successful?
            event = service.result
            # Persist the complete destination once the new record has its identifier.
            event.update!(url: "/calendar/events/#{event.id}")
            if scenario[:response]
                LesliCalendar::EventResponseOperator.new(owner, event.id).operate(response: scenario[:response])
            end
            if scenario[:reschedule]
                service.update(start_at: start_at + 1.hour, end_at: start_at + 2.hours)
                raise ActiveRecord::RecordInvalid.new(service.result) unless service.successful?
            end
            LesliCalendar::EventCancellationOperator.new(organizer, event.id).operate if scenario[:cancel]
        end
    end
end
