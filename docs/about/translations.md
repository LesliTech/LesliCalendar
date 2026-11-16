# Translations

LesliCalendar reserves the `lesli_calendar` namespace. Locale files are available for English, Spanish, French, Italian, and Portuguese.

Group labels by calendar feature:

```yaml
en:
  lesli_calendar:
    calendars:
      title: "Calendar"
      today: "Today"
    events:
      new: "New event"
      empty: "No events scheduled"
```

Use complete keys in views and services:

```erb
<%= I18n.t("lesli_calendar.events.new") %>
```

English and Spanish contain the implemented UI messages. French, Italian and Portuguese files are placeholders, not complete translations. Configure Rails fallbacks or supply translations before exposing those locales. Date and time formatting should use Rails locale formats rather than translated string fragments.

When LesliBabel is installed:

```shell
bin/rails lesli_babel:scan
bin/rails lesli_babel:import
```

Review generated changes and keep the engine locale files as the version-controlled source shipped with the gem.
