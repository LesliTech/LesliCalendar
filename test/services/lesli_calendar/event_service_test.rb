require "test_helper"

module LesliCalendar
    class EventServiceTest < LesliTesting::ModelTester
        test "agenda normalizes and groups upcoming FullCalendar events" do
            travel_to Time.zone.local(2026, 10, 11, 10, 0) do
                agenda = agenda_for([
                    {
                        id: 3,
                        title: "Tomorrow afternoon",
                        start: "2026-10-12T15:00:00Z",
                        classNames: ["lesli-calendar", "featured"],
                        extendedProps: { description: "<p>Planning session</p>" }
                    },
                    {
                        id: 2,
                        title: "Today at noon",
                        start: Time.zone.local(2026, 10, 11, 12, 0),
                        classNames: "lesli-support",
                        extendedProps: { description: "Customer follow-up" }
                    }
                ])

                assert_equal ["2026-10-11", "2026-10-12"], agenda.keys
                assert_equal "Today", agenda["2026-10-11"][:day_name]
                assert_equal "12:00", agenda["2026-10-11"][:day_number]
                assert_equal "lesli-support", agenda["2026-10-11"][:events].first[:classnames]
                assert_equal "Planning session", agenda["2026-10-12"][:events].first[:description]
                assert_equal "lesli-calendar featured", agenda["2026-10-12"][:events].first[:classnames]
            end
        end

        test "agenda excludes past events and events without a valid start" do
            travel_to Time.zone.local(2026, 10, 11, 10, 0) do
                agenda = agenda_for([
                    { title: "Past", start: Time.zone.local(2026, 10, 10, 23, 59) },
                    { title: "Missing", start: nil },
                    { title: "Invalid", start: "not-a-date" },
                    { title: "Upcoming", start: Time.zone.local(2026, 10, 11, 11, 0) }
                ])

                assert_equal ["Upcoming"], agenda["2026-10-11"][:events].pluck(:title)
            end
        end

        test "agenda sorts days and events chronologically" do
            travel_to Time.zone.local(2026, 10, 11, 8, 0) do
                agenda = agenda_for([
                    { title: "Tomorrow", start: "2026-10-12T09:00:00Z" },
                    { title: "Later", start: "2026-10-11T16:00:00Z" },
                    { title: "Earlier", start: "2026-10-11T09:00:00Z" }
                ])

                assert_equal ["2026-10-11", "2026-10-12"], agenda.keys
                assert_equal ["Earlier", "Later"], agenda["2026-10-11"][:events].pluck(:title)
            end
        end

        test "agenda supports string keys and normalizes end dates" do
            travel_to Time.zone.local(2026, 10, 11, 8, 0) do
                agenda = agenda_for([
                    {
                        "id" => 8,
                        "title" => "String payload",
                        "start" => "2026-10-11T09:00:00Z",
                        "end" => "2026-10-11T10:00:00Z",
                        "classNames" => "lesli-calendar",
                        "extendedProps" => { "description" => "Details" }
                    }
                ])

                event = agenda["2026-10-11"][:events].first

                assert_equal 8, event[:id]
                assert_equal "String payload", event[:title]
                assert_equal Time.zone.local(2026, 10, 11, 10, 0), event[:end_at]
                assert_equal "Details", event[:description]
            end
        end

        test "agenda removes markup and truncates long descriptions" do
            travel_to Time.zone.local(2026, 10, 11, 8, 0) do
                description = "<strong>Important</strong> #{'details ' * 20}"
                agenda = agenda_for([
                    {
                        title: "Long description",
                        start: "2026-10-11T09:00:00Z",
                        extendedProps: { description: description }
                    }
                ])

                result = agenda["2026-10-11"][:events].first[:description]

                refute_includes result, "<strong>"
                assert_operator result.length, :<=, 88
                assert_predicate result, :present?
            end
        end

        private

        def agenda_for(events)
            EventService.new.tap do |service|
                service.define_singleton_method(:index) { events }
            end.agenda
        end
    end
end
