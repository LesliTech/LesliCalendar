# Event Operations

EventService and the response/cancellation operators provide backend operations. Screen-level permissions remain the caller's responsibility through Core/LesliShield authorization. The services and operators additionally enforce account, event visibility, organizer ownership, and individual response rules. The operations are connected to the [Calendar Interface](/engines/calendar/about/interface), including invitation forms and participant responses.

## CRUD

```ruby
service = LesliCalendar::EventService.new(current_user).create(
    title: "Planning",
    url: "/support/tickets/42",
    start_at: 1.day.from_now,
    end_at: 1.day.from_now + 1.hour,
    public: false,
    user_ids: [colleague.id],
    role_ids: [role.id]
)

if service.successful?
    event = service.result
else
    submitted_event = service.result
    errors = submitted_event.errors
end
```

Account, organizer, default calendar, and initial status come from the server context and model defaults. Editable fields are `title`, `description`, `location`, `start_at`, `end_at`, `public`, and `url`. Callers cannot change ownership or reopen a cancelled event by submitting IDs or status.

```ruby
visible_events = LesliCalendar::EventService.new(current_user).index.result
service = LesliCalendar::EventService.new(current_user).show(event_id)
service.update(title: "Revised planning", user_ids: [another_user.id])

LesliCalendar::EventService.new(current_user).show(event_id).destroy
```

`index` returns a relation ordered by start time and ID through `result`. `show` and its alias `find` raise `ActiveRecord::RecordNotFound` for missing, deleted, foreign, or inaccessible events. Visible cancelled events remain readable. Only the organizer may update or delete; attempts by other users also raise `RecordNotFound` rather than allowing a mutation through a publicly visible record.

Invitations match direct users or current role memberships within the account. Acceptance does not independently grant private access. Public events are visible throughout the account. Role invitations require LesliShield; direct user and public events work without it.

## Replacing Invitations and Rescheduling

Omitting `user_ids` or `role_ids` preserves that selection; an empty array removes it. Blank entries are ignored and duplicate IDs are collapsed. Foreign or nonexistent recipients produce validation errors. Removing invitations does not delete response history. Users who still qualify through another invitation retain access; those losing their last private invitation lose access even if previously accepted.

Event changes, invitation replacement, and accepted-response resets share one transaction. Changes to start or end reset accepted responses to `pending` with a null `responded_at`; declined responses remain declined. Other content edits preserve responses. Former public participants can confirm the revised public event even without an explicit invitation.

Validation failures return an unsuccessful service with the submitted event and recipient IDs retained for form rendering. Database changes are rolled back, including inserted invitations and any earlier response resets. Use a fresh service per operation and check `successful?` before continuing.

## Responding

```ruby
attendant = LesliCalendar::EventResponseOperator
    .new(current_user, event_id)
    .operate(response: :accepted)

attendant = LesliCalendar::EventResponseOperator
    .new(current_user, event_id)
    .operate(response: :declined)
```

The operator accepts only `accepted` or `declined`, uses the authenticated user, and assigns the response timestamp on the server. Pending is an internal state for invitations/rescheduling. The organizer does not need to respond. Ended and cancelled events cannot receive responses.

Repeating the same answer returns the existing participation without changing its timestamp. Changing the answer updates that same record. A failed validation raises `ActiveRecord::RecordInvalid`; `exception.record` contains the rejected data and errors, while the previously stored response remains unchanged. Visibility failures raise `RecordNotFound`.

Responses never change the event's content or another participant's record. The event row lock serializes response changes with service edits, cancellation, and deletion; response visibility is checked again after acquiring the lock.

## Cancelling and Deleting

```ruby
event = LesliCalendar::EventCancellationOperator
    .new(current_user, event_id)
    .operate
```

Only the organizer may cancel. Repeated cancellation preserves the existing timestamp. Cancellation retains invitations and response history, prevents subsequent responses and edits, and excludes the event from the local personal calendar feed. Reopening is not supported. Deletion is soft deletion and also retains dependent history.

## Event Destination

Pass the complete destination when creating an event, for example `url: "/support/tickets/42"` or an HTTP/HTTPS URL. The calendar uses the stored `url` directly; it does not build or update routes automatically. If a module's mount path changes, update the stored destinations. An event without a URL has no navigation destination.

## Existing Calendar Consumer

`EventService#calendar_entries` retains the FullCalendar payload while `index` now follows the CRUD service contract. Its local entries include scheduled events organized or accepted by the current user, subject to current visibility. Reading an event or feed never creates an attendance record.
