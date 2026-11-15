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

## Calendar Range and Timezone

`GET /calendar/events.json?start=2026-11-01T00:00:00Z&end=2026-12-01T00:00:00Z`

The endpoint uses `calendar_entries`. Local events overlap when `start_at < range_end` and `end_at > range_start`, including events beginning before the range. The end is exclusive. Cancelled and deleted events are excluded. Without boundaries the service defaults to the current UTC month. Invalid ISO dates or reversed/empty ranges return HTTP 400.

Both FullCalendar and Agenda display **UTC**, independently of browser timezone. Request offsets are respected; feed timestamps use ISO 8601 UTC. Date-only boundaries mean midnight UTC. User-specific display zones are not implemented.

FullCalendar entries include `id`, `title`, `start`, `end`, `url`, `className`, and `extendedProps` with description and local event metadata.

## Agenda and Loading More

`EventService#agenda(page: 1)` returns day groups containing `day_name`, `day_number`, and `events`. Entries include `id`, `title`, a plain-text truncated description, `start_at`, `end_at`, `url`, and `class_name`.

Agenda includes events in progress, even from previous days, and future events. Events ending at or before now are excluded; deadline entries are excluded when their timestamp is in the past. Ordering is by start time, source, and ID. Day grouping uses the UTC start date, so ongoing events precede future events.

Pages contain at most 20 entries. Each source is limited in the database to the rows needed for the requested page plus one. `agenda_next_page` is nil when exhausted. Nested Turbo frames and Load more append subsequent pages. ERB does not query records. Pagination is offset-based; concurrent edits can shift subsequent pages.

## Optional Sources

Ticket deadlines use `Lesli::Courier` and `LesliSupport::TicketService#with_deadline`. Missing Support returns an empty collection; provider errors propagate. The provider applies account scoping and range boundaries and returns an ordered relation that Agenda limits before loading.

Support currently exposes account ticket deadlines. Local event invitation rules do not apply to tickets. More granular provider authorization and additional providers remain separate integration work. New providers should return scoped, ordered relations supporting database limits.

## Compatibility

The unused `LesliCalendar::Agenda` model and scaffold CRUD/views have been removed. Agenda remains the singular read-only `/calendar/agenda` route. There was no Agenda table or migration to remove.

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
