# wk-cal

> Use for all Google Calendar operations — fetching events, creating events in smart free slots, checking availability, and scanning for upcoming interviews.

**Version:** `2026.07.28-171032`

## Invocation

| Mode | Trigger |
|------|---------|
| User-invocable | "schedule a meeting", "check my calendar", "find time for X", "do I have interviews" |
| Model-invocable | automatic on: [`wk-sitrep`](../sitrep/README.md) `start` (interview prep scan) and `end` (tomorrow preview) |

## How It Works

```mermaid
flowchart TD
    A[Auth check via ToolSearch gcal] -->|MCP unavailable| B[Stop: ask user to<br/>check Gcal MCP settings]
    A -->|OK| C{Operation}
    C -->|Fetch events| D[list_events with<br/>time_min/max<br/>Extract title, attendees,<br/>links, recurrence]
    C -->|Create event| E[Collect title, duration,<br/>attendees, constraints]
    E --> F{Attendees}
    F -->|1-3| G[Fetch each calendar<br/>manually, find free windows]
    F -->|4+| H[get_free_busy across<br/>all attendee emails]
    G & H --> I[Score slots by penalty<br/>Conflicts, back-to-back, lunch]
    I --> J[Present best slot<br/>AskUser to confirm]
    J --> K[create_event]
    C -->|Interview scan| L[Fetch next 5 days<br/>Match interview keywords]
    L --> M[For each interview:<br/>Create 15-min prep block before<br/>Create 30-min scorecard block after]
    M --> N[Report scaffold status]
```

## Noteworthy

- **MCP auth is a hard gate** — if `ToolSearch("gcal")` returns no tools, the skill stops immediately; no fallback to manual date math or placeholder data.
- **Working hours are 9am–6pm** in the user's local timezone; lunch (12–1pm) is soft-protected with a scheduling penalty, never a hard block.
- **Debrief interviews skip the scorecard block** — debrief sessions are already the scorecard discussion, so only the 15-min prep block is created.
- **Slot ranking uses a penalty system** — conflicts add +3 per attendee, back-to-back adds +1, lunch window adds +2; lowest penalty wins with earlier-in-day as tiebreaker.
- **All calendar-touching skills delegate here** — [`wk-sitrep`](../sitrep/README.md) calls this skill rather than calling the Gcal MCP directly.
- **Scorecard blocks scan forward in 30-min increments** if the immediate post-interview slot is busy; if no same-day slot exists, it flags to the user rather than silently skipping.
