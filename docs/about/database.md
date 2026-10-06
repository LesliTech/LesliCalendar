# Database

LesliCalendar uses collection code `03` and engine code `01`. Only tables created by the current migrations are part of its schema contract.

| Migration code | Table | Responsibility | Important relationships |
| --- | --- | --- | --- |
| `03.01.00.01.10` | `lesli_calendar_accounts` | Engine state for a Lesli account | Required core account reference |
| `03.01.10.01.10` | `lesli_calendar_calendars` | Account calendars | Calendar account and core user |
| `03.01.11.01.10` | `lesli_calendar_events` | Scheduled event data | Calendar, core account, and core user |
| `03.01.11.10.10` | `lesli_calendar_event_attendants` | Users attending an event | Event and core user |

Calendars, events, and attendants include indexed `deleted_at` columns. Events reference both the engine calendar and core account; queries must preserve both ownership boundaries.

The previous documentation listed planned catalogs, workflows, discussions, attachments, guests, and proposals. Those tables do not exist in the current migrations and are not part of the supported schema.

```shell
bin/rails lesli:db:prepare
bin/rails db:migrate:status
```

See [Database Architecture](/engines/lesli/database/structure) and [Migration Versioning](/engines/lesli/database/versioning).
