# Interview Prep Scan

Run during `wk-sitrep start` to ensure every upcoming interview has the right
calendar scaffolding. Covers the next 5 calendar days.

## Step 1: Detect interviews

Fetch events for next 5 days via `Fetch Day Events`. Flag events with
interview-signal keywords (case-insensitive):

```
interview | phone screen | technical screen | coding interview |
behavioral | hiring panel | debrief | onsite | system design | loop
```

Also flag if description mentions "candidate" or "hiring".

## Step 2: For each detected interview

**Skip rule:** If title contains `debrief`, create only the Prep block -- skip
Scorecard (debrief sessions are already the scorecard discussion).

### A. 15-min Interview Prep block (immediately before)

Check if 15 minutes before interview start are free via `list_events` on the primary calendar (single calendar —
no free/busy needed; every non-declined event is busy, including unanswered and tentative):
- Free: create event `"Interview Prep -- {title}"` with description "Review
  candidate profile, questions, and role context."
- Busy: note conflict; do not create.

### B. 45-min Interview Scorecard block (after)

**HARD RULE:** The scorecard is always a booked calendar event, never a checkbox
or to-do item. Create via calendar MCP before any caller renders its summary.

- Duration: 45 min by default; a user-stated length always wins.
- First try immediately after interview end.
- If busy (any non-declined event, including unanswered or tentative), scan forward in 15-min steps through the rest
  of the working day.
- Pick the first window free for the **full** duration — never shorten the block to fit a gap.
- No same-day slot: flag to user with warning.

### C. Verify every created block

Re-list the day after each `create_event`; assert start, end, duration, and zero overlap with non-declined events.
Mismatch → move/resize or report `[warn]`; never report `created` before this passes.

## Step 3: Report

Surface results as part of morning brief or evening preview:

```
Interview scaffolding:
  [check] {title} ({date} {time})
     Prep: {time} -- created
     Scorecard: {time} -- created
  [warn] {title} ({date} {time})
     Prep: could not create -- {conflict reason}
     Scorecard: no same-day slot -- manual action needed
```
