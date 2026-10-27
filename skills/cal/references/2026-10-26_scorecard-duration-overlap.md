---
class: principle
source: learnings/skills/cal/2026-10-26_scorecard-duration-overlap.learned.md
date: 2026-10-26
skill: wk-cal
---

**Rule** — Treat every non-declined event (accepted, tentative, unanswered) as busy; pick a window free for the full
requested duration; re-list the day after every `create_event` and assert start, end, duration, and zero overlap
before reporting the event as created. Scorecard default is 45 min; a user-stated length wins.

**Why** — A scorecard block was booked 30 min (45 requested) on top of an unanswered meeting. The scan hard-coded 30
min, free-slot detection treated a no-RSVP event as free, and nothing re-read the calendar to catch either error. A
successful create call proves the write happened, not that the placement is right.

**Caller text** — The calling skill's interview-block stage restates the old 30-min length; that correction lands with
the caller-owned learning on the same incident, not in this fold.

**Where** — `SKILL.md` → §Smart Event Creation Step 2 (busy definition), Step 4 (verify HARD RULE), §Interview Prep
Scan (45-min default); `interview-prep-scan.md` → Step 2A, 2B, 2C.
