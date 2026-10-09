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

Check if 15 minutes before interview start are free via `get_free_busy`:
- Free: create event `"Interview Prep -- {title}"` with description "Review
  candidate profile, questions, and role context."
- Busy: note conflict; do not create.

### B. 30-45-min Interview Scorecard block (after)

**HARD RULE:** The scorecard is always a booked calendar event, never a checkbox
or to-do item. Create via calendar MCP before any caller renders its summary.

- First try immediately after interview end (30min).
- If busy, scan forward in 30-min increments through rest of working day.
- Pick first free slot of at least 30 minutes.
- No same-day slot: flag to user with warning.

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
