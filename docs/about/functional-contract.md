# Functional Contract

The rules below define event ownership, visibility, invitations, and responses. The calendar feed covers the requested visible local range; see [Calendar and Agenda](/engines/calendar/about/calendar-and-agenda) for its implemented scope.

## Account Boundary and Organizer

Every event belongs to a local `LesliCalendar::Account`. Its author is its organizer; both are the same user in this version. The server assigns the account and organizer from the authenticated context. Ordinary updates cannot transfer either value.

Public means discoverable by authenticated users **within the same Core account**. It does not mean anonymous access, an internet-facing URL, or visibility across accounts. Every lookup, invitation, response, and external calendar source must preserve this boundary.

## Visibility and Invitations

An event is either public or private:

- A public event can be viewed and accepted by any authorized user in its account. Explicit invitations identify intended recipients but do not restrict public visibility.
- A private event is visible to its organizer and users invited directly or through a current role membership.
- Matching either a user invitation or a role invitation is sufficient. Multiple matches do not duplicate the event or its response.
- A private event without invitations is personal to its organizer.

Only users and roles belonging to the event's account may be selected. Role membership is evaluated using current membership rather than copying role members into a fixed recipient list. Role invitations require LesliShield; public events and direct user invitations must work without it.

Being able to view an event does not imply permission to edit it. Showing a link or hiding a button is not an access check: these rules must also apply to detail pages, JSON feeds, and mutations.

## Personal Calendar and Discovery

| User relationship | Can view the event | Included in My Calendar |
| --- | --- | --- |
| Organizer | Yes | Yes |
| Eligible invitee, pending response | Yes | No |
| Eligible invitee, accepted response | Yes | Yes |
| Eligible invitee, declined response | Yes | No |
| Same-account user, public event, no response | Yes | No |
| Same-account user, public event, accepted response | Yes | Yes |
| Private event, no current invitation | No | No |
| User from another account | No | No |

All rows remain subject to the relevant application permissions. Cancelled events are excluded from active calendar and Agenda feeds.

My Calendar contains events the user organizes and events they have accepted and can still access. Invitations lists currently eligible invitations awaiting a response. Available Events lets users discover public events without automatically subscribing them. An uninvited public event is available to accept but is not itself a pending invitation.

Opening a page never accepts or declines an event. External records such as ticket deadlines are separate calendar entries: displaying them does not create an event, invitation, or attendance record.

## Individual Responses

The response states are `pending`, `accepted`, and `declined`:

- An eligible invitation with no response is pending; generating one pending row per role member is not required.
- Acceptance adds the event to the user's personal calendar.
- Declining removes it from the personal calendar without removing access to an otherwise visible event.
- A user can change between accepted and declined while the event has not ended or been cancelled and the user remains eligible.
- A public event can be accepted without a prior explicit invitation.
- Repeating the same response is idempotent and does not create duplicate participation records or change the original response timestamp unnecessarily.
- The organizer is included automatically and does not need to accept their own event.

Responses always belong to the authenticated user. The organizer may manage invitations but cannot accept or decline on another user's behalf. Historical events remain readable when authorized, but attendance responses are no longer editable after the event ends.

## Permission Rules

LesliShield supplies action permissions when installed. Calendar additionally enforces account, ownership, and visibility rules. If Shield is absent, Core's authorization fallback does not remove these record-level restrictions.

| Operation | Required relationship, in addition to action permission |
| --- | --- |
| Create | Authenticated user in the current account |
| View | Organizer, eligible private invitee, or same-account public viewer |
| Edit event or invitations | Organizer |
| Cancel or delete | Organizer |
| Accept, decline, or change response | Current eligible user, acting only for themselves |

There is no implicit administrator override for private event access or organizer-only mutations in this first version. Delegation, transferring ownership, and managing another user's attendance are outside the initial scope.

Cancellation preserves the event and response history, prevents new responses, and removes the event from active feeds. An authorized detail page shows that it was cancelled. Deletion is a separate soft-delete operation that hides the event from normal lookup; it is not the standard way to communicate cancellation. Reopening cancelled events is outside this first version.

## Removing Invitations and Changing Roles

Removing one invitation does not remove access when another valid invitation still applies. For example, removing a direct invitation has no effect on private access if the user remains in an invited role.

When the final valid invitation to a private event disappears, the user loses access and the event disappears from their calendar, even if previously accepted. The response may remain as history; it never grants access independently of the current audience.

If eligibility is restored, the existing response remains applicable provided it has not been reset by a schedule change. This avoids creating a separate invitation history workflow in the first version. Removing an invitation from a public event does not revoke access or acceptance: public access still applies within the account.

Changing visibility from public to private immediately applies the private audience rules. Users without a current invitation lose access even if they previously accepted. Changing from private to public broadens discovery, but never automatically accepts the event for additional users.

## Timezone Policy

Event instants are stored in UTC. Forms and displayed dates use the user's profile
timezone, with `Lesli.config.datetime[:time_zone]` as the global fallback.
Changing the display timezone never moves an event or resets participation.
Users select their timezone in their profile; login and browser changes do not update it.
See [Calendar and Agenda](calendar-and-agenda.md#local-time-and-utc-storage)
for detection, fallback behavior and API expectations.

## Schedule Changes

Both start and end are mandatory. The end must be strictly later than the start; malformed dates are rejected. A scheduled event defaults to private visibility, with defaults defined in the models.

Changing the actual start or end instant resets accepted responses to pending in the same transaction as the event update. Those users must accept the new schedule before it returns to their personal calendars. The organizer remains included automatically.

Declined responses remain declined, and pending responses remain pending. Changes to title, description, location, or link do not reset responses. A timezone display change representing the same instants is not a reschedule.

Rescheduling a public event must not lose the previous participants from the pending-invitations view merely because they originally joined without an explicit invitation. Their pending participation remains a request to confirm the new schedule, subject to current visibility.

Resetting a response does not imply sending email or creating a notification. Delivery integrations are separate future work.

## Agenda Views

Agenda groups Upcoming events, My events, Pending invitations and Available public
events in one page. My events supports optional date filters and historical
records; Pending and Available use their respective visibility and participation
queries. See [Calendar and Agenda](calendar-and-agenda.md) for the query contract.

The default Upcoming view is not limited to today. It uses the same personal
eligibility rules as My Calendar and may include authorized external entries.

- Include events in progress and future events; exclude events that have ended or been cancelled.
- Include ongoing events that started on a previous day.
- Show ongoing events first, then upcoming events by ascending start time.
- Use stable source/record identifiers to break ties.
- Show each entry's own time, origin, and destination.
- Apply one explicit display timezone consistently to grouping and date labels.
- Upcoming is bounded to the current month. Agenda currently has no pagination.

External deadlines are point-in-time entries, not meetings with attendance. Past-due work may be shown by a separate overdue widget; it must not be silently treated as an ongoing meeting.

## Initial Scope

The first version supports local events, direct and role invitations, public discovery, individual responses, cancellation, My Calendar, and Agenda. It keeps one default account calendar; personal calendars are filtered views, not one database calendar per user.

Google Calendar synchronization, external email invitees, recurring events, reminders, approval workflows, and delegated organizers are outside this contract. Later phases must add tests for each rule before considering it implemented.
