require "test_helper"

class CalendarAgendaViewTest < ActionView::TestCase
    include LesliCalendar::Engine.routes.url_helpers
    include Turbo::FramesHelper

    setup do
        view.extend LesliCalendar::Engine.routes.url_helpers
    end

    test "empty agenda uses translated text" do
        @agenda = {}
        I18n.with_locale(:es) do
            render partial: "lesli_calendar/partials/agenda"
            assert_select "p", text: "No hay próximos eventos."
        end
    end

    test "agenda links to records and escapes event content" do
        @agenda = { "2026-11-14" => { day_name: "Today", day_number: "14", events: [
            { url: "/support/tickets/7", title: "<script>unsafe</script>", description: "<b>text</b>", class_name: "lesli-calendar" }
        ] } }
        render partial: "lesli_calendar/partials/agenda"
        assert_select "a[href='/support/tickets/7'][data-turbo-frame='_top']"
        assert_select "script", count: 0
        assert_select "b", count: 0
    end
end
