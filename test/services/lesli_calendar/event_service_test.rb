require "test_helper"

module LesliCalendar
    class EventServiceTest < LesliTesting::ModelTester
        test "agenda keeps ongoing and future entries in chronological order" do
            travel_to Time.utc(2026, 11, 14, 12) do
                entries = [
                    { title: "Future", start: Time.iso8601("2026-11-15T12:00:00Z") },
                    { title: "Ended", start: Time.iso8601("2026-11-14T10:00:00Z"), end: Time.iso8601("2026-11-14T11:00:00Z") },
                    { title: "Ongoing", start: Time.iso8601("2026-11-13T12:00:00Z"), end: Time.iso8601("2026-11-14T13:00:00Z") }
                ]
                service = EventService.new(nil)
                service.define_singleton_method(:calendar_entries) { entries }
                agenda = service.agenda
                assert_equal [Date.new(2026, 11, 13), Date.new(2026, 11, 15)], agenda.keys
                assert_equal ["Ongoing", "Future"], agenda.values.flat_map { |day| day[:events].pluck(:title) }
            end
        end

        test "agenda groups UTC entries by the local date" do
            Time.use_zone("America/Guatemala") do
                travel_to Time.utc(2026, 11, 14, 12) do
                    entries = [{ title: "Late meeting", start: Time.utc(2026, 11, 15, 2), end: Time.utc(2026, 11, 15, 3) }]
                    service = EventService.new(nil)
                    service.define_singleton_method(:calendar_entries) { entries }
                    agenda = service.agenda
                    assert_equal [Date.new(2026, 11, 14)], agenda.keys
                    assert_equal 20, agenda.values.first[:events].first[:start_at].hour
                end
            end
        end

        test "agenda presents plain text descriptions and keeps the destination" do
            travel_to Time.utc(2026, 11, 14, 12) do
                entries = [{ title: "Ticket", start: Time.iso8601("2026-11-15T12:00:00Z"), url: "/support/tickets/1",
                    extendedProps: { record_id: 1, source: "support", description: "<b>Details</b> #{'words ' * 30}" } }]
                service = EventService.new(nil)
                service.define_singleton_method(:calendar_entries) { entries }
                event = service.agenda.values.first[:events].first
                assert_equal 1, event[:record_id]
                assert_equal "support", event[:source]
                assert_equal "/support/tickets/1", event[:url]
                refute_includes event[:description], "<b>"
                assert_operator event[:description].length, :<=, 88
            end
        end
    end
end
