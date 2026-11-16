# Dashboard Widgets

LesliCalendar declares three widgets through `LesliCalendar::Dashboard::COMPONENTS`.
LesliDashboard discovers them through its existing catalog, with a default width
of four columns each.

| Widget | Content | Limit |
| --- | --- | --- |
| `upcoming_events` | Scheduled events organized or accepted by the current user, including ongoing events | Five, ordered by start time and ID |
| `pending_invitations` | Agenda's pending collection, including reconfirmation after rescheduling | Five, ordered by start time and ID |
| `upcoming_deadlines` | External calendar entries, currently Support ticket deadlines through Courier | Five earliest entries within the next 30 days |

External sources apply their own account scope and permissions. Missing or failed
optional sources use Courier's empty-array fallback; Courier reports errors.
The deadline widget limits displayed entries after receiving the date-bounded
source results. External records are not copied into Calendar.

Each render resolves `current_user` and uses the active profile/application zone.
There is no shared fragment or account-level cache for personal entries. Local
event links open Calendar details; ticket URLs come from Support and open there.
Links leave any enclosing Turbo Frame. All widgets have translated empty states
and an Agenda link. Upcoming Agenda remains scoped to the current month; the
deadline widget's rolling 30-day window can extend into the next month.

New dashboards receive these initial widgets through account initialization.
Existing dashboards are not changed by deployment or repeated registration:
add widgets through **Edit widgets** in LesliDashboard. Registration preserves
existing layouts and removed widgets.

Available public events remain accessible through Agenda. A dedicated widget is
deferred to keep the initial dashboard small: the current catalog uses the same
definitions for available and initial widgets.

Partials use the current user even when rendered from central LesliDashboard
administration. They do not depend on controller-specific instance variables.
