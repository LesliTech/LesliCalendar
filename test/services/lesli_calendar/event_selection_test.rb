require "test_helper"

module LesliCalendar
    class EventSelectionTest < LesliTesting::ModelTester
        setup do
            @account = Lesli::Account.create!(name: "Queries", email: "queries@example.test", status: :active)
            @author = user("author")
            @reader = user("reader")
            @service = EventService.new(@reader)
        end

        def user(name)
            record = @account.users.new(email: "#{name}-queries@example.test")
            if record.respond_to?(:password=)
                record.password = "Password123!"
                record.confirmed_at = Time.current
            end
            record.save!
            record
        end

        def event(**attributes)
            result = EventService.new(@author).create({title: "Meeting", start_at: 1.hour.from_now, end_at: 2.hours.from_now}.merge(attributes))
            assert result.successful?, result.errors_as_sentence
            result.result
        end

        test "personal pending and public collections keep participation separate" do
            private_event = event
            invited = event(user_ids: [@reader.id])
            public_event = event(public: true)
            assert_empty @service.my_calendar.result
            assert_equal [invited.id], @service.pending_invitations.result.pluck(:id)
            assert_equal [public_event.id], @service.available_events.result.pluck(:id)
            EventResponseOperator.new(@reader, invited.id).operate(response: :accepted)
            assert_equal [invited.id], @service.my_calendar.result.pluck(:id)
            assert_empty @service.pending_invitations.result
            EventResponseOperator.new(@reader, public_event.id).operate(response: :declined)
            assert_includes @service.available_events.result, public_event
            refute_includes @service.my_calendar.result, private_event
            EventCancellationOperator.new(@author, public_event.id).operate
            assert_empty @service.available_events.result
        end

        test "dashboard queries are personal ordered and limited" do
            event(title: "Private to organizer")
            pending = 7.times.map { |index| event(title: "Invitation #{index}", user_ids: [@reader.id],
                start_at: (index + 2).hours.from_now, end_at: (index + 3).hours.from_now) }
            assert_empty @service.dashboard_entries(:upcoming_events)
            assert_equal pending.first(5).map(&:id), @service.dashboard_entries(:pending_invitations)
                .map { |entry| entry[:extendedProps][:record_id] }

            EventResponseOperator.new(@reader, pending.last.id).operate(response: :accepted)
            assert_equal [pending.last.id], @service.dashboard_entries(:upcoming_events)
                .map { |entry| entry[:extendedProps][:record_id] }
            assert_empty EventService.new(user("uninvited")).dashboard_entries(:pending_invitations)
            assert_equal 5, EventService.new(@author).dashboard_entries(:upcoming_events).size
        end

        test "deadline widget uses the external source with a bounded range and five entries" do
            travel_to Time.utc(2026, 11, 14, 12) do
                ranges = []
                @service.define_singleton_method(:external_calendar_entries) do |start_at:, end_at:|
                    ranges << [start_at, end_at]
                    7.times.map { |index| { id: "ticket:#{index}", start: start_at + index.days,
                        title: "Ticket #{index}", url: "/support/tickets/#{index}" } }.reverse
                end
                entries = @service.dashboard_entries(:upcoming_deadlines)
                assert_equal [[Time.current, Time.current + 30.days]], ranges
                assert_equal (0..4).map { |index| "ticket:#{index}" }, entries.pluck(:id)
                assert_equal "/support/tickets/0", entries.first[:url]
            end
        end

        test "changing a profile zone changes agenda dates without changing events or responses" do
            travel_to Time.utc(2026, 11, 2) do
                meeting = event(start_at: Time.utc(2026, 11, 15, 0, 30),
                    end_at: Time.utc(2026, 11, 15, 1, 30), user_ids: [@reader.id])
                EventResponseOperator.new(@reader, meeting.id).operate(response: :accepted)
                participation = meeting.attendants.find_by!(user: @reader)
                original_event = meeting.reload.attributes
                original_response = participation.attributes

                { "Europe/Berlin" => Date.new(2026, 11, 15), "America/Guatemala" => Date.new(2026, 11, 14) }.each do |zone, date|
                    @reader.update!(time_zone: zone)
                    Time.use_zone(@reader.effective_timezone) do
                        assert_equal [date], @service.agenda(view: "mine").keys
                        entry = @service.calendar_entries.sole
                        assert_equal Time.utc(2026, 11, 15, 0, 30), entry[:start]
                    end
                    assert_equal original_event, meeting.reload.attributes
                    assert_equal original_response, participation.reload.attributes
                end
            end
        end

        test "visible range respects offsets across a daylight saving transition" do
            spanning = event(start_at: Time.utc(2027, 3, 27, 22), end_at: Time.utc(2027, 3, 28, 1))
            event(start_at: Time.utc(2027, 3, 27, 21), end_at: Time.utc(2027, 3, 27, 23))
            event(start_at: Time.utc(2027, 3, 28, 22), end_at: Time.utc(2027, 3, 28, 23))
            Time.use_zone("Europe/Berlin") do
                entries = EventService.new(@author,
                    start: "2027-03-28T00:00:00+01:00", end: "2027-03-29T00:00:00+02:00").calendar_entries
                assert_equal [spanning.id], entries.map { |entry| entry[:extendedProps][:record_id] }
            end
        end

        test "range uses overlap and exclusive boundaries" do
            travel_to Time.utc(2026, 11, 14, 12) do
                spanning = event(start_at: Time.utc(2026, 10, 31), end_at: Time.utc(2026, 11, 2))
                inside = event(url: "/support/tickets/42")
                event(start_at: Time.utc(2026, 10, 30), end_at: Time.utc(2026, 11, 1))
                event(start_at: Time.utc(2026, 12, 1), end_at: Time.utc(2026, 12, 2))
                entries = EventService.new(@author).calendar_entries
                assert_equal [spanning.id, inside.id], entries.map { |entry| entry[:extendedProps][:record_id] }
                assert entries.all? { |entry| entry[:start].utc? }
                assert_equal "/support/tickets/42", entries.last[:url]
                assert_equal "/support/tickets/42", inside.reload.url
                assert_nil entries.first[:url]
            end
        end

        test "upcoming Agenda is chronological and bounded to the active month" do
            Time.use_zone("America/Guatemala") do
                travel_to Time.zone.local(2026, 11, 14, 9) do
                    event(title: "Ended", start_at: 2.hours.ago, end_at: 1.hour.ago)
                    ongoing = event(title: "Ongoing", start_at: 1.hour.ago, end_at: 1.hour.from_now)
                    future = event(title: "Future", start_at: 2.hours.from_now, end_at: 3.hours.from_now)
                    event(title: "Next month", start_at: Time.zone.local(2026, 12, 1), end_at: Time.zone.local(2026, 12, 1, 1))
                    entries = EventService.new(@author).agenda.values.flat_map { |day| day[:events] }
                    assert_equal [ongoing.id, future.id], entries.pluck(:record_id)
                end
            end
        end

        test "role eligibility follows current memberships and never crosses accounts" do
            skip "LesliShield is optional" unless defined?(LesliShield)
            role = @account.roles.first!
            invited = event(role_ids: [role.id])
            membership = LesliShield::User::Role.create!(user: @reader, role: role)
            assert_equal [invited.id], @service.pending_invitations.result.pluck(:id)
            EventResponseOperator.new(@reader, invited.id).operate(response: :accepted)
            assert_equal [invited.id], @service.my_calendar.result.pluck(:id)
            membership.destroy!
            assert_empty @service.my_calendar.result
            assert_empty @service.pending_invitations.result
            other = Lesli::Account.create!(name: "Other queries", email: "other-queries@example.test", status: :active)
            invited.update!(account: other.calendar, calendar: other.calendar.default_calendar, user: other.users.create!(email: "other-query@example.test", password: "Password123!", confirmed_at: Time.current))
            assert_empty @service.my_calendar.result
        end
    end
end
