require "test_helper"

class CalendarSourcesTest < ActiveSupport::TestCase
    setup do
        skip "This integration requires LesliSupport and LesliShield" unless defined?(LesliSupport) && defined?(LesliShield)
    end

    test "Calendar combines local events and permitted Support deadlines without leaking accounts" do
        account, user = create_context("calendar-source")
        other_account, other_user = create_context("calendar-other")
        event = LesliCalendar::EventService.new(user).create(
            title: "Personal meeting", start_at: 1.hour.from_now, end_at: 2.hours.from_now
        ).result
        ticket = create_ticket(account, user, "Visible deadline")
        create_ticket(other_account, other_user, "Other account deadline")
        query = { start: Time.current.iso8601, end: 1.day.from_now.iso8601 }

        assert_equal ["lesli_calendar:event:#{event.id}"], LesliCalendar::EventService.new(user, query).calendar_entries.pluck(:id)

        role = account.roles.first!
        LesliShield::User::Role.create!(user: user, role: role)
        LesliShield::Role::Privilege.create!(role: role, controller: "lesli_support/tickets", action: "show", active: true)
        user.reload
        entries = LesliCalendar::EventService.new(user, query).calendar_entries
        assert_equal ["lesli_calendar:event:#{event.id}", "lesli_support:ticket:#{ticket.id}"], entries.pluck(:id)
        assert_equal "/support/tickets/#{ticket.id}", entries.last[:url]
    end

    private

    def create_context(label)
        account = Lesli::Account.create!(name: label, email: "#{label}@example.test", status: :active)
        user = account.users.create!(email: "#{label}@example.test", password: "Password123!", confirmed_at: Time.current)
        [account, user]
    end

    def create_ticket(account, user, subject)
        account.support.tickets.create!(uid: "TKT-#{SecureRandom.hex(4)}", subject: subject,
            user: user, owner: user, deadline_at: 3.hours.from_now)
    end
end
