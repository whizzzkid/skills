---
name: wk-cal
description: >-
  Use for all Google Calendar operations — fetching events, creating events in
  smart free slots, checking availability across attendees, and scanning for
  upcoming interviews to automatically schedule prep and scorecard blocks.
  Invoked by wk-sitrep (start: interview prep scan; end: tomorrow preview) and
  directly for any calendar management task.
argument-hint: '[fetch-today | fetch-range <start> <end> | create | interview-prep-scan]'
allowed-tools:
  - ToolSearch
  - AskUserQuestion
  - Agent
model: sonnet
effort: low
model-invocable: true
user-invocable: true
license: MIT
group: rituals
metadata:
  author: whizzzkid
  version: "2026.10.09-005006"
  model:
    openai: gpt-5.6-terra
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-1.5
---

# 📅 Calendar

Canonical calendar operations for Google Calendar via MCP. All skills that
interact with calendar data delegate here.

## Auth Check

**HARD RULE:** Always perform this check first.

Before any calendar operation, verify the Google Calendar MCP is available:

```
ToolSearch("gcal")
```

If no tools are returned, tell the user:

> Google Calendar MCP is not connected. Check your MCP settings and ensure
> the Gcal integration is enabled, then retry.

Stop immediately — do not attempt calendar operations without MCP access.
Do not fall back to manual date math or placeholder data.

## Working Hours

Default working window: **9:00 AM – 6:00 PM** in the user's local timezone.
Never schedule events outside this window unless the user explicitly requests it.
Lunch window (12:00–1:00 PM) is soft-protected — prefer not to schedule here.

## § Fetch Day Events

Canonical pattern for fetching events for a given day or range. Used by
`wk-sitrep` (start: today; end: today + tomorrow preview).

```
gcal.list_events(
  calendar_id: "primary",
  time_min: "<date>T00:00:00",
  time_max: "<date>T23:59:59",
  single_events: true,
  order_by: "startTime"
)
```

For each event extract:
- Title, start time, end time, duration
- Attendees list (flag the organizer)
- Location or video conference link
- Description / notes field
- Whether it is a recurring event
- Any linked document URLs in the description

Skip all-day events that are auto-generated (e.g., out-of-office banners,
public holidays) unless the user is the organizer.

## § Smart Event Creation

Use this when asked to schedule a new event. Never just pick a time — always
find a free slot.

### Step 1: Understand the event

Collect from the user or context:
- Title and intended duration
- Required attendees (names or emails)
- Preferred date range (default: this week or next business day)
- Any hard constraints (e.g., "after 2pm", "not Monday")

### Step 2: Fetch busy blocks

For **1–3 attendees**, fetch the primary calendar's events for each candidate
day and identify free windows manually.

For **4+ attendees**, use `get_free_busy` across all attendee emails to find
genuine overlap:

```
gcal.get_free_busy(
  time_min: "<range_start>",
  time_max: "<range_end>",
  items: [{ id: "<email>" }, ...]
)
```

Parse the response: for each candidate slot, count how many attendees have a
conflict. Rank slots by **fewest conflicts** — the slot where the most
attendees are free, weighted by seniority/necessity if provided.

### Step 3: Rank candidate slots

Score each 30-minute window inside working hours:

| Condition | Penalty |
|---|---|
| Outside 9am–6pm | Disqualify |
| Lunch window (12–1pm) | +2 (prefer to avoid) |
| Back-to-back with another meeting (no buffer) | +1 |
| Attendee conflict | +3 per conflicting attendee |
| Already used as a focus block | +1 |

Pick the slot with the lowest total penalty. If there is a tie, prefer
earlier in the day. If no slot has zero conflicts for large groups, pick the
lowest-conflict option and surface the conflict list to the user for a call.

### Step 4: Confirm and create

Present the proposed time to the user:

> "Best slot found: **{day} {time}** ({duration}). {N} of {M} attendees are
> free. Proceed?"

After confirmation, create the event:

```
gcal.create_event(
  calendar_id: "primary",
  summary: "<title>",
  start: { dateTime: "<ISO8601>", timeZone: "<tz>" },
  end:   { dateTime: "<ISO8601>", timeZone: "<tz>" },
  attendees: [{ email: "<email>" }, ...],
  description: "<optional notes>"
)
```

## § Interview Prep Scan

Run during `wk-sitrep start` to ensure every upcoming interview has prep and
scorecard blocks. See
[references/interview-prep-scan.md](references/interview-prep-scan.md) for the
full scan protocol (detection keywords, debrief skip rule, prep/scorecard
creation, and reporting format).

**HARD RULE:** The scorecard is always a booked calendar event, never a
checkbox or to-do item. Create via calendar MCP before any caller renders.

## Quick Reference

| Invocation | Behavior |
|---|---|
| `wk-sitrep start` | Automatically runs `§ Interview Prep Scan` for next 5 days |
| `wk-sitrep end` | Uses `§ Fetch Day Events` for today + tomorrow preview |
| "schedule a meeting" / "find time for X" | Runs `§ Smart Event Creation` |
| "check my calendar" / "what's on today" | Runs `§ Fetch Day Events` for today |
| "do I have interviews coming up" | Runs `§ Interview Prep Scan` |
| MCP unavailable | Stop and ask user to check Gcal MCP settings |

---

## Post-Completion

Invoke `wk-learn cal`.
