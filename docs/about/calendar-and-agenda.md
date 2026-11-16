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
| `mine` | Scheduled events organized or accepted by the current user | Includes history; optional `from` and `to` ISO dates filter overlapping events in the active timezone, with the final date inclusive |
| `pending` | Invitations awaiting a response | Ongoing and future events |
| `available` | Public events the user can join | Ongoing and future events not organized or accepted by the user |

The Agenda controller defaults to `upcoming` and rejects unknown views with
HTTP 400. Date filters apply only to `mine`; malformed dates return HTTP 400.
There is no pagination or Load more action. Only the default Upcoming view is
bounded to the current month; the other views do not inherit that restriction.

Future improvement: paginate **My events** after applying its date filters.
Without filters, it currently loads the full personal event history. Pagination
should preserve the selected view and date filters and use a stable chronological
order (`start_at`, then `id`). It is not implemented in this version.

Entries are sorted by start time and grouped by start date. Each group contains
`day_name`, `day_number`, and `events`. Each entry provides `title`, `url`,
`start_at`, `end_at`, `source`, `status`, `record_id`, `class_name`, and a plain-text
description truncated to 88 characters.

The UI selects the view in the URL, for example `/calendar/agenda?view=pending`.
Calendar events open the shared detail panel, including events without a stored
URL. Ticket links continue to open Support. See [Calendar Interface](interface.md)
for sidebar navigation and panel behavior.

## Local Time and UTC Storage

The timezone policy is:

1. Store event instants in UTC.
2. Use `Lesli::User#time_zone` when the user has selected a profile preference.
3. Otherwise use `Lesli.config.datetime[:time_zone]` from the initializer, then
   the Rails application timezone if the Lesli setting is absent.

Core applies this zone with `Time.use_zone` for each request, including services,
LesliDate formatting, forms and Agenda. FullCalendar receives the same IANA zone
from Rails. Browser location and device timezone do not change this preference.
Login does not detect or save a timezone, and there is no timezone cookie,
session setting or automatic page reload. Users can change their zone in their
profile; clearing it restores the application default.

The installed FullCalendar 7.1.3 supports IANA zones through its existing Temporal
integration; no timezone plugin is required. Rails supplies `data-time-zone`,
which the custom element passes as FullCalendar's `timeZone` option. The active
zone is visible above the calendar, in the Agenda heading, on datetime form
labels and in the event detail panel.

Changing a profile timezone changes presentation and the local dates used for
filtering and grouping. It does not update an event's UTC timestamps, status,
invitations or participation responses, and does not request reconfirmation.
A genuine event reschedule remains a separate operation.

The datetime-local form values are interpreted in that zone; Active Record
persists UTC timestamps. For example, 09:00 in `America/Guatemala` is stored as
15:00 UTC and displays as 09:00 when reopened in that timezone. IANA zones apply
the offset for the event date, including daylight saving time where applicable.
No fixed numeric offset is stored on the event.

FullCalendar uses the zone supplied by Rails; its ISO range timestamps include offsets
and the service normalizes them to UTC for queries. Event feed timestamps remain
UTC. Agenda groups entries and applies date filters in the active timezone;
monthly queries use local month boundaries. Forms and detail views display the
active timezone explicitly.

API clients should send ISO 8601 datetimes with `Z` or an explicit offset to
identify instants without relying on a session timezone. Calls outside an HTTP
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


### Provider contract

`EventService#external_calendar_entries(start_at:, end_at:)` delegates to the
explicit Support source through Courier. `calendar_entries` concatenates those
results with local events; the deadline widget reuses the same source. Adding
another provider means adding an explicit Courier call here, not a new table.

Providers receive the authenticated user and an inclusive start/exclusive end
range. They must apply their own account and record permissions before returning
an array of FullCalendar entries, for example:

```ruby
{
    id: "lesli_support:ticket:42",
    title: "Customer follow-up",
    start: ticket.deadline_at.utc,
    end: nil,
    url: "/support/tickets/42",
    className: "lesli-support",
    extendedProps: {
        record_id: 42,
        source: "support",
        status: "deadline",
        description: "Contact the customer"
    }
}
```

Use a unique engine/type/record ID and return the destination from the owning
module. Dates must be temporal values representing instants. A normal empty
array means no authorized records match; a provider exception is reported by
Courier before falling back to an empty array. Tasks without a deadline remain
outside this feed.

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
