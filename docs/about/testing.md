# Testing and Release Verification

Run the standalone suite from the engine directory with a test database:

```shell
RAILS_ENV=test bundle exec rake db:migrate
RAILS_ENV=test bundle exec rake test
```

Keep migration and test commands separate. The migration process can retain a
database connection; PostgreSQL cannot purge a test database while another
process is connected. Never point `DATABASE_URL` at development or production
data: Rails test preparation may replace the schema.

The dummy registers both Calendar and Core migration paths before schema loading.
The migration history loaded from `schema.rb` therefore includes Core's older
versions. Keep Rails' `maintain_test_schema` enabled; no manual migration-version
inserts or disabled pending-migration checks are needed.

For PostgreSQL, include `pg` in the test bundle and run the same commands with a
dedicated `DATABASE_URL`. An isolated schema dump can be selected with `SCHEMA`:

```shell
export RAILS_ENV=test
export DATABASE_URL=postgresql://localhost/lesli_calendar_test
export SCHEMA=/tmp/lesli_calendar_postgresql_schema.rb
bundle exec rake db:migrate
bundle exec rake test
```

Use an isolated test bundle with LesliShield for the role scenarios. Without
Shield, direct invitations, public events, CRUD and widgets still run; only
role-membership scenarios are skipped. Run the installed framework versions
together, including the Core profile-timezone column.

From LesliBuilder, verify the host suite and Calendar under all mounted engines:

```shell
RAILS_ENV=test bin/rails db:migrate
bin/rails test
bin/rails test engines/LesliCalendar/test
```

Builder's `CalendarSourcesTest` checks the real Calendar → Courier → Support
path: missing ticket privileges exclude deadlines, granted privileges include
only the current account, and Support supplies the destination URL.

## Coverage

- CRUD, account scope, private/public visibility and organizer-only mutations.
- Direct and role invitations, combined audiences and dynamic membership.
- Acceptance, rejection, repeated responses and access after invitation removal.
- Cancellation, rescheduling, reconfirmation and transactional rollback.
- Date validation, overlap, exclusive range boundaries, UTC and daylight saving.
- Profile timezone changes without modifying events or participation history.
- Agenda ordering/month boundaries and five-entry dashboard widget limits.
- Missing and failed optional providers, including error reporting.
- HTML/Turbo/JSON, retained form values, escaping, translations and mounted links.
- Repeatable demo seeds and database foreign keys, nullability and unique indexes.

Upcoming Agenda is bounded to the active month. Other Agenda views are not
paginated; My events pagination remains a documented future improvement. Widget
limits do not imply an Agenda row limit.

SQLite and PostgreSQL run the same constraint tests. Business validations on
attendant responses intentionally remain in the model; uniqueness, references
and required fields are enforced by the database.

## Verification baseline — 2026-11-15

Verified with Ruby 3.3.5, Rails 8.1.4 and the local framework packages:

| Execution | Result |
| --- | --- |
| Calendar standalone, SQLite, with Shield | 61 passed |
| Calendar standalone, SQLite, without Shield | 59 passed, 2 role tests skipped |
| Calendar standalone, PostgreSQL 17, with Shield | 61 passed |
| Calendar inside LesliBuilder, SQLite | 61 passed |
| Builder integration suite, SQLite | 5 passed |
| Builder system smoke tests (`rack_test`) | 2 passed |
| Empty-database schema loading: Core user tests | 14 passed |
| Empty-database schema loading: Calendar data contract | 9 passed |

The system smoke tests do not execute browser JavaScript. Turbo response and
frame behavior are covered by controller/view tests; browser-level interaction
is not claimed by this baseline. All databases used here were disposable.
