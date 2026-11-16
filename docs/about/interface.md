# Calendar Interface

Calendar uses LesliView forms, headers, buttons, and panels. Event operations use the existing services and operators; controllers do not assign another account or organizer from submitted parameters.

## Routes

Paths below assume the standard `/calendar` engine mount:

| Path | Action |
| --- | --- |
| `GET /calendar/calendar` | Personal calendar grid. |
| `GET /calendar/events` | Redirect to Agenda, My events. |
| `GET /calendar/events.json?start=2026-11-01T00:00:00Z&end=2026-12-01T00:00:00Z` | Entries overlapping the requested range; used by FullCalendar. |
| `GET /calendar/events.json?month=2026-11` | Optional monthly query; without a range or month, uses the current month in the active timezone. |
| `GET /calendar/events/pending` | Redirect to Agenda, Pending invitations. |
| `GET /calendar/events/available` | Redirect to Agenda, Available public events. |
| `GET /calendar/events/new` | Creation form. |
| `POST /calendar/events` | Create an event and its invitations. |
| `GET /calendar/events/:id` | Visible event details and current response. |
| `GET /calendar/events/:id/edit` | Organizer's edit form. |
| `PATCH /calendar/events/:id` | Update the event and selected invitations. |
| `PATCH /calendar/events/:id/cancel` | Cancel without deleting participation history. |
| `DELETE /calendar/events/:id` | Organizer-only soft deletion. |
| `PATCH /calendar/events/:event_id/attendant` | Set the authenticated user's response. |
| `GET /calendar/agenda` | Agenda views; defaults to upcoming entries in the current month. |

The singular attendant route resolves to `LesliCalendar::Event::AttendantsController`. It accepts `attendant[response]` (`accepted` or `declined`) and never takes a participant identity from the request. The old scaffold attendant CRUD has been removed.

## Forms and Responses

Forms use datetime fields interpreted in the active profile or application timezone, plain text descriptions, an optional complete destination, privacy, and account-scoped user/role selectors. Role selection is available when Shield is installed. Empty selections replace invitations; omitted parameters preserve them.

Validation failures return HTTP 422 and retain submitted fields and selections. Turbo replaces the form; HTML re-renders its page; JSON returns an `errors` object. Successful HTML/Turbo mutations redirect with HTTP 303. JSON creation returns 201 and subsequent mutations return 200. Page GETs following Turbo redirects render HTML. Account isolation and organizer rules are enforced in addition to the existing screen authorization.

Prev, Today and Next use FullCalendar's navigation. Rails supplies the feed URL;
FullCalendar sends the visible local range as `start` and `end` (exclusive),
including adjacent days. `datesSet` only updates the title. The initial viewport
selects month, week or day; resizing does not switch the view. FullCalendar manages
range loading and caching, with an explicit refresh only after a successful
Turbo form submission inside the event panel. The grid has no custom loading,
empty-period or request-error status messages.

See [Calendar and Agenda](calendar-and-agenda.md) for query parameters and lifecycle details.

Agenda shows each entry's time in the active timezone, state, source, and destination. It has no persistent model or scaffold CRUD.

## Existing Installations

New routes need to be registered in the host's privilege catalog. Run the normal configuration workflow before granting or testing the corresponding permissions:

```shell
bin/rails lesli:db:prepare
```

This uses the existing resource registration, account initialization, and Shield privilege synchronization. Custom roles still require an administrator to select their permissions; Calendar does not grant access itself.

## Demo Seeds

The development/demo seeder visits configured Calendar accounts and uses their first user as the primary demo user. When a second user exists, it adds invitations organized by that colleague. Role examples use an existing role of the primary user; no users, role memberships, or permissions are created by this seeder.

Scenarios include personal and private inaccessible events, public discovery, direct and role invitations, combined invitations, accepted/declined/pending responses, rescheduling requiring reconfirmation, cancellation with preserved participation, ongoing/overnight/completed events, UTC date boundaries, cancelled public events, and month boundaries. The original JSON examples are spread predictably across the previous, current, and next month.

Demo titles have a `Demo:` prefix. Repeating the seeder preserves records with the same title, including soft-deleted records. Renaming a demo title permits that example to be recreated on the next run. Each new event gets its complete detail path stored in `url`; changing the mount path requires updating those stored destinations.

To load only Calendar's seeds after configuration:

```shell
bin/rails runner 'load LesliCalendar::Engine.root.join("db/seeds.rb")'
```

Demo data is loaded only in development or when `Lesli.config.demo` is enabled. Existing demo dates are not shifted on subsequent runs.

## Event Detail Panel

Clicking a Calendar event in FullCalendar or Agenda opens its detail in the existing LesliView panel.
Agenda uses the event ID for this detail link, even when the event has no destination URL.
The panel loads the authorized event through a Turbo Frame and reuses the
regular detail and edit views. On the Calendar page, successful edits,
cancellations and invitation responses refresh the grid without changing the
visible period. In Agenda, successful panel submissions reload only the list's Turbo Frame,
using its current view and date filters. The panel remains open and failed
submissions do not refresh the list.
Validation errors remain in the panel. Organizer action buttons appear below
the detail in a wrapping group, leaving the panel header for its title and close control. Deleting an event returns to My events in Agenda.

The event's stored `url` remains its optional **Open destination** action.
External entries, such as Support ticket deadlines, follow the URL supplied
by their owning engine instead of opening the Calendar panel. Direct links
to an event still render the complete detail page.

The shared event panel handles missing-frame responses and network errors with
local Alpine listeners, in both Calendar and Agenda. It displays a translated
alert without discarding the current form. Starting another request clears the
alert. Normal validation responses continue to display their form errors.

## Agenda Navigation

The main navigation contains Dashboard, Calendar and Agenda. Agenda selects its
view through `?view=upcoming|mine|pending|available`; the default is `upcoming`.
The standard LesliView navigation sidebar lists these views beside the content
on desktop and collapses into a disclosure on smaller screens. New event sits
in the page header, while date filters remain with the event list. Each sidebar
option has its own Remix Icon: calendar tasks for Upcoming, calendar events for
My events, unread mail for Pending, and a globe for Available public events.
The mobile disclosure displays the selected option's label and icon.

- **Upcoming events** keeps the existing current-month summary of ongoing and
  upcoming personal events and external entries, ordered chronologically.
- **My events** lists scheduled events organized by the current user or accepted
  by them, including past events. Optional `from` and `to` ISO dates filter
  overlapping events in the active timezone; the final date is inclusive.
- **Pending invitations** lists invitations awaiting a response.
- **Available public events** lists accessible public events not yet accepted.

All views reuse EventService visibility and account scopes. Calendar events open
in the shared detail panel; external ticket links continue to open LesliSupport.
The previous HTML event-list URLs redirect to the corresponding Agenda view.
Their JSON responses remain available, including the FullCalendar events feed.
