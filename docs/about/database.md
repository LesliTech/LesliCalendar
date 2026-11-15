# Database

LesliCalendar uses collection code `03` and engine code `01`. Its account, calendars, and events belong to the local Calendar workspace, linked to the Core account through `LesliCalendar::Account#account`.

| Migration code | Table | Responsibility |
| --- | --- | --- |
| `03.01.00.01.10` | `lesli_calendar_accounts` | One workspace per Core account |
| `03.01.10.01.10` | `lesli_calendar_calendars` | Named account calendars; initially one named `default` |
| `03.01.11.01.10` | `lesli_calendar_events` | Event content, organizer, schedule, and visibility |
| `03.01.11.10.10` | `lesli_calendar_event_attendants` | One individual response per event and user |
| `03.01.11.11.10` | `lesli_calendar_event_user_invitations` | Direct user invitations |
| `03.01.11.11.10` | `lesli_calendar_event_role_invitations` | Role invitations |

Table names follow Rails conventions and the isolated engine namespace, including nested models such as `Event::Attendant`. No `self.table_name` overrides are needed.

## Calendar and Event Contract

Account initialization creates the calendar named `default`. `Account#default_calendar` finds that exact name and raises if it is missing. `CalendarService#find(id)` uses the requested ID within the authenticated account; it does not silently substitute the first calendar. A partial unique index prevents duplicate live calendar names within one workspace.

Calendar defaults (`name: "default"`, `color: "0d52bf"`) live in the model. Calendars no longer have an unused `user_id`; personal calendars will be filtered views of events rather than separately owned containers.

Events require a nonblank title, organizer (`user`), calendar, local Calendar account, start, and end. The end is mandatory and must be strictly later than the start. Malformed dates are rejected. The calendar must belong to the event's local account, and the organizer must belong to the corresponding Core account.

The model defaults to `status: "scheduled"` and `public: false`. The only statuses are `scheduled` and `cancelled`. These defaults are not database defaults: raw inserts must supply the required values. The database also enforces the allowed statuses and a positive event interval. Optional URLs accept internal paths or HTTP/HTTPS destinations. Description uses a text column.

## Invitations and Responses

Events expose `user_invitations`, `role_invitations`, `invited_users`, `invited_roles`, and `attendants`. Each invitation belongs to an event and an explicit Core user or role. Recipients must belong to the event's Core account. Both invitation tables have required foreign keys and a unique event/recipient pair.

`Event::Attendant` stores `response` (`pending`, `accepted`, or `declined`) and `responded_at`. Pending is the model default and requires a null response timestamp. Accepted and declined require a valid timestamp. The model alone validates the response states and their timestamp requirements, so these business rules can change without a database migration. A unique event/user index prevents duplicate responses; the response operator updates the same record for a changed answer and preserves timestamps on repeated identical answers.

Invitation and response models inherit directly from Active Record and do not have `deleted_at`. Removing an invitation is a physical deletion. Declining is a response update, not a deletion. Role availability, authorization to respond, response timestamps, and transactional response transitions are handled by the [event operations](/engines/calendar/about/event-operations).

## Cancellation and Deletion

Account, Calendar, and Event inherit Core's soft-delete behavior. Cancellation changes event status; deleting an event sets its `deleted_at`. Neither operation destroys invitations or responses, so history remains stored. No cascading foreign-key deletion is configured. The local calendar feed excludes cancelled events, and the response operator rejects new responses to them. The associations alone do not enforce those operations.

## Development Schema Changes

Original migrations have been updated while Calendar data is disposable:

- `draft`, `proposal`, and `approved` are replaced by `scheduled` and `cancelled`.
- Event title, dates, organizer, calendar, visibility, and status are required.
- `confirmed_at` is replaced by `response` and `responded_at`.
- Attendance soft deletion is removed; invitation tables are added.
- Calendar ownership by user is removed and defaults move into the models.

Rebuild existing disposable development/test databases to adopt these changes; running `db:migrate` alone will not rerun edited migrations. Rebuilding deletes data. Consumers needing to preserve records require an explicit data migration; none is provided for legacy records.

The dummy schema and Builder schema include this contract. Model tests exercise account relations, explicit calendar lookup, defaults, date and URL validation, uniqueness, foreign keys, and history retention.

See [Functional Contract](/engines/calendar/about/functional-contract), [Database Architecture](/engines/lesli/database/structure), and [Migration Versioning](/engines/lesli/database/versioning).
