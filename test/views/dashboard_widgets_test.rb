require "test_helper"

class CalendarDashboardWidgetsTest < ActionView::TestCase
    setup do
        view.extend Rails.application.routes.mounted_helpers
    end

    test "widgets render translated empty states and agenda links" do
        I18n.with_locale(:es) do
            LesliCalendar::Dashboard::COMPONENTS.each do |kind|
                render partial: "lesli_calendar/dashboards/widget", locals: { kind: kind, entries: [] }
                assert_select "h2", text: I18n.t("lesli_calendar.widgets.#{kind}")
                assert_select "p", text: I18n.t("lesli_calendar.widgets.#{kind}_empty")
            end
        end
    end

    test "widgets escape titles and preserve external destinations" do
        Time.use_zone("America/Guatemala") do
            render partial: "lesli_calendar/dashboards/widget", locals: {
                kind: :upcoming_deadlines,
                entries: [{ title: "<script>unsafe</script>", start: Time.utc(2027, 1, 15, 15), url: "/support/tickets/7" }]
            }
            assert_select "script", count: 0
            assert_select "a[href='/support/tickets/7'][data-turbo-frame='_top']"
            assert_select "time", text: I18n.l(Time.zone.local(2027, 1, 15, 9), format: :short)
        end
    end

    test "local events link to their detail instead of an optional destination" do
        render partial: "lesli_calendar/dashboards/widget", locals: {
            kind: :upcoming_events, entries: [{ title: "Meeting", start: Time.current,
                url: "https://example.com", extendedProps: { source: "calendar", record_id: 12 } }]
        }
        assert_select "a[href=?][data-turbo-frame='_top']", view.lesli_calendar.event_path(12)
        assert_select "a[href='https://example.com']", count: 0
    end
end
