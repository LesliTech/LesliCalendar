# Installation

LesliCalendar provides account-scoped calendars, events, and attendees. It requires Lesli `~> 5.1.0` and stores calendar data in the host database.

## Install and Mount

```shell
bundle add lesli_calendar
```

The standard router mounts it at `/calendar`:

```ruby
Rails.application.routes.draw do
  Lesli::Router.mount(self)
end
```

For a manual mount:

```ruby
Rails.application.routes.draw do
  mount LesliCalendar::Engine => "/calendar"
end
```

Prepare the database and initialize existing accounts:

```shell
bin/rails lesli:db:prepare
```

## Verify the Installation

```shell
bin/rails routes -g calendar
bin/rails server
```

Visit `http://127.0.0.1:3000/calendar`. The mounted engine exposes a singleton calendar with nested event operations.

See [Translations](/engines/calendar/about/translations) and [Database](/engines/calendar/about/database) for development conventions.
