# Calendar and Agenda

Calendar and Agenda are views of events, not separate persistent resources. All local queries start from the authenticated user's account and current event visibility.

## Separate Collections

`EventService` exposes service results containing lazy Active Record relations:

- `my_calendar`: scheduled events organized by the user or accepted by that user, provided they remain visible. Historical events remain available for calendar navigation.
- `pending_invitations`: ongoing or future invitations without an accepted/declined response, plus explicit pending responses after rescheduling. The organizer is excluded.
- `available_events`: ongoing or future public events in the account, excluding events the user organizes or has accepted. Declined events remain available to change the response.

Direct and current role invitations match with OR semantics and never duplicate events. Losing an invitation removes private access even after acceptance; historical responses remain stored. Public discovery and pending invitations can overlap. Neither automatically adds an event to My Calendar.

```ruby
service = LesliCalendar::EventService.new(current_user)
service.pending_invitations.result
```

## Calendar Feed

FullCalendar loads the JSON URL supplied by Rails through `data-events-url`.
There is no hardcoded fallback URL. Its requests include ISO 8601 `start` and
`end` timestamps for the visible range, including adjacent days from other
months. The end boundary is exclusive. Both timestamps are required when either
is supplied; malformed timestamps return HTTP 400.

`EventService#calendar_entries` also accepts `month=YYYY-MM` for explicit monthly
queries. Without a range or month, it uses the current month in the active timezone. An explicit
range takes precedence over `month`; malformed month values return HTTP 400
when using the monthly query.

```ruby
service = LesliCalendar::EventService.new(
    current_user,
    start: "2026-11-01T00:00:00Z",
    end: "2026-12-01T00:00:00Z"
)
service.calendar_entries
```

The service maps local events to FullCalendar hashes, obtains ready-to-render
ticket entries through Courier using `LesliSupport::TicketService#calendar_entries`,
and concatenates both arrays. The same range is passed to Support. Local events
are included when they overlap the range, even if they began earlier; ticket
deadlines must fall within it. Rails serializes the time objects as JSON.

Local entries retain the stored event `url` as an optional destination. The
Calendar interface opens local event details in its panel using the record ID;
**Open destination** follows the stored URL. Support supplies its own ticket
URLs, which navigate directly to Support. Calendar does not construct them.

## Agenda

`EventService#agenda(view: "upcoming", from: nil, to: nil)` supplies four views:

| View | Entries | Date scope |
| --- | --- | --- |
| `upcoming` | Personal events and external entries, including ticket deadlines | Current month; keeps ongoing entries and removes finished events and past deadlines |
| `mine` | Scheduled events organized or accepted by the current user | Includes history; optional `from` and `to` ISO dates filter overlapping events in the browser timezone, with the final date inclusive |
| `pending` | Invitations awaiting a response | Ongoing and future events |
| `available` | Public events the user can join | Ongoing and future events not organized or accepted by the user |

The Agenda controller defaults to `upcoming` and rejects unknown views with
HTTP 400. Date filters apply only to `mine`; malformed dates return HTTP 400.
There is no pagination or Load more action. Only the default Upcoming view is
bounded to the current month; the other views do not inherit that restriction.

Entries are sorted by start time and grouped by start date. Each group contains
`day_name`, `day_number`, and `events`. Each entry provides `title`, `url`,
`start_at`, `end_at`, `source`, `status`, `record_id`, `class_name`, and a plain-text
description truncated to 88 characters.

The UI selects the view in the URL, for example `/calendar/agenda?view=pending`.
Calendar events open the shared detail panel, including events without a stored
URL. Ticket links continue to open Support. See [Calendar Interface](interface.md)
for sidebar navigation and panel behavior.

## Local Time and UTC Storage

Users create, edit and view events in their browser's timezone. The shared
navigation detects its IANA name with `Intl.DateTimeFormat`, stores it in the
`lesli_calendar_time_zone` session cookie, and reloads once when the server's
rendered timezone differs. Rails applies that zone with `Time.use_zone` for
Calendar requests. Missing or invalid browser zones fall back to `Lesli.config.datetime[:time_zone]`,
then to the Rails application timezone when no Lesli timezone is configured.
JavaScript and cookies are required to detect the browser zone.

The datetime-local form values are interpreted in that zone; Active Record
persists UTC timestamps. For example, 09:00 in `America/Guatemala` is stored as
15:00 UTC and displays as 09:00 when reopened in that timezone. IANA zones apply
the offset for the event date, including daylight saving time where applicable.
No fixed numeric offset is stored on the event.

FullCalendar uses `timeZone: "local"`; its ISO range timestamps include offsets
and the service normalizes them to UTC for queries. Event feed timestamps remain
UTC. Agenda groups entries and applies date filters in the browser timezone;
monthly queries use local month boundaries. Forms and detail views display the
active timezone explicitly.

API clients should send ISO 8601 datetimes with `Z` or an explicit offset to
identify instants without relying on a browser cookie. Calls outside an HTTP
request use the current Rails timezone for values without an offset.

Existing timestamps are not rewritten. Records previously entered as UTC keep
the same instants and now display in local time; correct individual records if
the original input was intended to mean a different instant.

## FullCalendar Lifecycle

The `lesli-calendar` custom element lives in LesliAssets's `source/js/calendar.js`.
It creates one FullCalendar instance and cleans it up when disconnected or before
Turbo caches the page. Listeners share one AbortController signal; disconnecting
removes them, and the custom-element registration guard prevents duplicate registration.

- Rails supplies the feed URL, event detail URL template, locale and title target.
- The initial viewport selects a month on desktop, a week on tablet, or a day on mobile.
  There is no custom resize handler to switch views afterward.
- Prev, Today and Next use FullCalendar navigation. `datesSet` only updates the title.
- FullCalendar manages range loading and caching. There is no separate `visibleMonth`
  state or extra refetch after changing periods.
- A successful Turbo form submission inside `calendar-event-detail` explicitly
  refreshes the grid without resetting its visible period. Unrelated forms and
  failed submissions do not trigger that refresh.
- The grid has no custom loading, empty-period or request-error status messages.
  Detail-panel errors are handled separately by the shared panel.
- Event titles are rendered with `textContent`, not interpreted as HTML.

## Optional Sources

Courier uses an empty-array fallback when an engine is absent or fails. With `fallback_on_error: true`, Courier reports errors through Rails and the other sources still render. There is no extra source-status protocol or browser warning in this version.


## Frontend Styles

Calendar and agenda templates use Tailwind utilities. FullCalendar creates its internal markup at runtime, so its component rules live in the engine Tailwind entrypoint:

```text
source/tailwind/application.css
```

Do not edit the compiled asset directly:

```text
app/assets/stylesheets/lesli_calendar/application.css
```

From a complete Lesli development workspace, compile the source through LesliAssets:

```shell
cd gems/LesliAssets
make build.tailwind
```

The entrypoint uses explicit `@source` declarations. Add every new view or helper that contains Tailwind classes, otherwise those utilities will not be present in the generated stylesheet.

Event-source classes are styling hooks rather than Tailwind utilities assembled at runtime. Define complete selectors for any new source in the Tailwind entrypoint so Tailwind can compile the associated rules.
