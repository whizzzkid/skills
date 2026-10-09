---
name: wk-cal
description: >-
  Use for all Google Calendar operations — fetching events, creating events in
  smart free slots, checking availability across attendees, and scanning for
  upcoming interviews to automatically schedule prep and scorecard blocks.
  Invoked by wk-sitrep (start: interview prep scan; end: tomorrow preview).
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
  version: "2026.10.09-184159"
  model:
    openai: gpt-5.6-terra
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-1.5
---

# 📅 Calendar

All skills that touch calendar data delegate here.

## Auth Check

**HARD RULE:** Always perform this check first, before any calendar operation:

```
ToolSearch("gcal")
```

No tools returned → tell the user:

> Google Calendar MCP is not connected. Check your MCP settings and ensure
> the Gcal integration is enabled, then retry.

Then stop immediately: no calendar operations without MCP access, no fallback to
manual date math or placeholder data.

## Working Hours

Default window: **9:00 AM – 6:00 PM** user-local. Never schedule outside it unless
the user explicitly requests it. Lunch (12:00–1:00 PM) is soft-protected: prefer
not to schedule there.

## § Fetch Day Events

Used by `wk-sitrep` (start: today; end: today + tomorrow preview) and "check my
calendar" / "what's on today".

```
gcal.list_events(
  calendar_id: "primary",
  time_min: "<date>T00:00:00",
  time_max: "<date>T23:59:59",
  single_events: true,
  order_by: "startTime"
)
```

Extract per event: title, start, end, duration; attendees (flag the organizer);
location or video link; description/notes; recurring or not; linked document URLs
in the description. Skip auto-generated all-day events (out-of-office banners,
public holidays) unless the user is the organizer.

## § Smart Event Creation

For "schedule a meeting" / "find time for X": never just pick a time — always
find a free slot.

### Step 1: Understand the event

Collect from user or context: title and duration; required attendees (names or
emails); preferred date range (default: this week or next business day); hard
constraints ("after 2pm", "not Monday").

### Step 2: Fetch busy blocks

**1–3 attendees:** fetch the primary calendar's events per candidate day and find
free windows manually. **4+ attendees:** use `get_free_busy` across all attendee
emails for genuine overlap:

```
gcal.get_free_busy(
  time_min: "<range_start>",
  time_max: "<range_end>",
  items: [{ id: "<email>" }, ...]
)
```

Count conflicting attendees per candidate slot; rank by **fewest conflicts**,
weighted by seniority/necessity if provided.

### Step 3: Rank candidate slots

Score each 30-minute window inside working hours:

| Condition | Penalty |
|---|---|
| Outside 9am–6pm | Disqualify |
| Lunch window (12–1pm) | +2 (prefer to avoid) |
| Back-to-back with another meeting (no buffer) | +1 |
| Attendee conflict | +3 per conflicting attendee |
| Already used as a focus block | +1 |

Pick the lowest total penalty; tie → earlier in the day. No zero-conflict slot
for a large group → pick the lowest-conflict option and surface the conflict list
to the user for a call.

### Step 4: Confirm and create

Propose: "Best slot found: **{day} {time}** ({duration}). {N} of {M} attendees
are free. Proceed?" After confirmation, create:

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

Run during `wk-sitrep start` (or on "do I have interviews coming up") so every
upcoming interview has prep and scorecard blocks. Follow
[references/interview-prep-scan.md](references/interview-prep-scan.md) (detection
keywords, debrief skip rule, prep/scorecard creation, reporting format).

**HARD RULE:** The scorecard is always a booked calendar event, never a
checkbox or to-do item. Create via calendar MCP before any caller renders.

## Post-Completion

Invoke `wk-learn cal`.
