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

## Current Month

`EventService#calendar_entries` returns FullCalendar entries for the current UTC month: from midnight on its first day to midnight on the first day of the next month (exclusive). Request range parameters are not used. Browsing another month does not fetch that month's events in this version.

The service maps local events directly to FullCalendar hashes, obtains ticket deadlines through Courier, maps those tickets, and concatenates both arrays. Rails serializes the time objects in the JSON response. Local entries use the event’s stored `url` unchanged. Supply the complete destination when creating the event; mount changes require updating stored URLs. Ticket entries use `/support/tickets/:id`. Local events that overlap the month are included even when they started earlier; ticket deadlines must fall inside the month.

## Agenda

`EventService#agenda` uses the same monthly entries, removes finished events and past deadlines, sorts chronologically, and groups by start date. It keeps ongoing events. Descriptions are plain text, truncated for presentation, and links open the owning module.

There is no pagination or Load more action. Agenda does not list events beyond the current month.

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
