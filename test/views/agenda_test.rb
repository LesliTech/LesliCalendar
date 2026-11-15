require "test_helper"

class CalendarAgendaViewTest < ActionView::TestCase
    include LesliCalendar::Engine.routes.url_helpers
    include Turbo::FramesHelper

    setup do
        view.extend LesliCalendar::Engine.routes.url_helpers
    end

    test "empty agenda and load more use translated text and matching Turbo targets" do
        @agenda = {}
        @agenda_page = 1
        @agenda_next_page = 2
        I18n.with_locale(:es) do
            render partial: "lesli_calendar/partials/agenda"
            assert_select "turbo-frame#agenda_page_1"
            assert_select "p", text: "No hay próximos eventos."
            assert_select "turbo-frame#agenda_page_2 a[data-turbo-frame='agenda_page_2']", text: "Cargar más"
        end
    end

    test "last page has no next frame and escapes event content" do
        @agenda_page = 2
        @agenda_next_page = nil
        @agenda = { "2026-11-14" => { day_name: "Today", day_number: "14", events: [
            { title: "<script>unsafe</script>", description: "<b>text</b>", class_name: "lesli-calendar" }
        ] } }
        render partial: "lesli_calendar/partials/agenda"
        assert_select "turbo-frame#agenda_page_2"
        assert_select "turbo-frame#agenda_page_3", count: 0
        assert_select "script", count: 0
        assert_select "b", count: 0
    end
end
