# Calendar and Agenda

LesliCalendar presents the same event collection in two forms:

- The calendar uses FullCalendar to render a responsive day, week, or month grid.
- The agenda is rendered by Rails and groups upcoming events chronologically by day.

Both views use `LesliCalendar::EventService` as their data source.

## Event Sources

`EventService#index` combines events from the account's default calendar with ticket deadlines from LesliSupport. The LesliSupport integration is optional; `Lesli::Courier` returns an empty collection when that engine or service is unavailable.

The resulting hashes follow FullCalendar's event-object structure:

| Key | Purpose |
| --- | --- |
| `id` | Source record identifier |
| `title` | Text displayed for the event |
| `start` and `end` | Event timestamps |
| `url` | Optional event destination |
| `classNames` | Source-specific CSS classes such as `lesli-calendar` or `lesli-support` |
| `extendedProps` | Description, location, status, and visibility metadata |

The JSON endpoint consumed by FullCalendar is:

```text
GET /calendar/events.json
```

## Agenda Transformation

`EventService#agenda` converts the FullCalendar payload into the structure used by the server-rendered agenda partial. It:

1. Parses Rails date objects and ISO 8601 strings in the application timezone.
2. Excludes events before the beginning of the current day.
3. Ignores events whose start value is missing or invalid.
4. Sorts events chronologically and groups them under ISO date keys.
5. Removes HTML from descriptions and truncates them for display.

Each group has the following shape:

```ruby
{
  "2026-10-11" => {
    day_name: "Today",
    day_number: "14:30",
    events: [
      {
        id: 42,
        title: "Planning session",
        description: "Review the next release...",
        start_at: Time.zone.parse("2026-10-11T14:30:00-06:00"),
        end_at: nil,
        url: nil,
        classnames: "lesli-calendar"
      }
    ]
  }
}
```

Keep `index` compatible with FullCalendar. When adding another event source, map its records to the FullCalendar structure in `index`; `agenda` will then normalize that shared payload for the list view.

## Frontend Styles

Calendar and agenda templates use Tailwind utilities. FullCalendar creates its internal markup at runtime, so its component rules live in the engine Tailwind entrypoint:

```text
source/tailwind/application.tailwind.css
```

Do not edit the compiled asset directly:

```text
app/assets/stylesheets/lesli_calendar/application.tailwind.css
```

From a complete Lesli development workspace, compile the source through LesliAssets:

```shell
cd gems/LesliAssets
make build.tailwind
```

The entrypoint uses explicit `@source` declarations. Add every new view or helper that contains Tailwind classes, otherwise those utilities will not be present in the generated stylesheet.

Event-source classes are styling hooks rather than Tailwind utilities assembled at runtime. Define complete selectors for any new source in the Tailwind entrypoint so Tailwind can compile the associated rules.
