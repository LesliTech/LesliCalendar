require "test_helper"

module LesliCalendar
    class EventQueryTest < LesliTesting::ModelTester
        setup do
            @account = Lesli::Account.create!(name: "Queries", email: "queries@example.test", status: :active)
            @author = user("author")
            @reader = user("reader")
            @query = EventQuery.new(@reader)
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
            assert_empty @query.personal
            assert_equal [invited.id], @query.pending.pluck(:id)
            assert_equal [public_event.id], @query.available.pluck(:id)
            EventResponseOperator.new(@reader, invited.id).operate(response: :accepted)
            assert_equal [invited.id], @query.personal.pluck(:id)
            assert_empty @query.pending
            EventResponseOperator.new(@reader, public_event.id).operate(response: :declined)
            assert_includes @query.available, public_event
            refute_includes @query.personal, private_event
            EventCancellationOperator.new(@author, public_event.id).operate
            assert_empty @query.available
        end

        test "range uses overlap and exclusive boundaries" do
            travel_to Time.utc(2026, 11, 14, 12) do
                spanning = event(start_at: 2.days.ago, end_at: 2.days.from_now)
                inside = event
                event(start_at: 2.days.ago, end_at: Time.current)
                event(start_at: 1.day.from_now, end_at: 2.days.from_now)
                query = EventQuery.new(@author)
                assert_equal [spanning.id, inside.id], query.overlapping(Time.current, 1.day.from_now).pluck(:id)
                entries = EventService.new(@author, start: "2026-11-14T06:00:00-06:00", end: "2026-11-15T12:00:00Z").calendar_entries
                assert_equal [spanning.id, inside.id], entries.pluck(:id)
                assert entries.all? { |entry| entry[:start].end_with?("Z") }
                assert_raises(ArgumentError) { EventService.new(@author, start: "bad").calendar_entries }
                assert_raises(ArgumentError) { EventService.new(@author, start: "2026-11-15", end: "2026-11-14").calendar_entries }
            end
        end

        test "agenda includes ongoing events and paginates with a stable tie break" do
            travel_to Time.utc(2026, 11, 14, 12) do
                ongoing = event(start_at: 2.days.ago, end_at: 1.hour.from_now)
                event(start_at: 2.hours.ago, end_at: Time.current)
                upcoming = 21.times.map { event(start_at: 1.day.from_now, end_at: 2.days.from_now) }
                service = EventService.new(@author)
                first = service.agenda.values.flat_map { |day| day[:events] }
                assert_equal [ongoing.id] + upcoming.first(19).map(&:id), first.pluck(:id)
                assert_equal 2, service.agenda_next_page
                second_service = EventService.new(@author)
                second = second_service.agenda(page: 2).values.flat_map { |day| day[:events] }
                assert_equal upcoming.last(2).map(&:id), second.pluck(:id)
                assert_nil second_service.agenda_next_page
            end
        end

        test "role eligibility follows current memberships and never crosses accounts" do
            skip "LesliShield is optional" unless defined?(LesliShield)
            role = @account.roles.first!
            invited = event(role_ids: [role.id])
            membership = LesliShield::User::Role.create!(user: @reader, role: role)
            assert_equal [invited.id], @query.pending.pluck(:id)
            EventResponseOperator.new(@reader, invited.id).operate(response: :accepted)
            assert_equal [invited.id], @query.personal.pluck(:id)
            membership.destroy!
            assert_empty @query.personal
            assert_empty @query.pending
            other = Lesli::Account.create!(name: "Other queries", email: "other-queries@example.test", status: :active)
            invited.update!(account: other.calendar, calendar: other.calendar.default_calendar, user: other.users.create!(email: "other-query@example.test", password: "Password123!", confirmed_at: Time.current))
            assert_empty @query.personal
        end
    end
end
