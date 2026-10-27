---
skill: wk-cal
date: 2026-10-26
type: gap
severity: medium
verified-against-source: yes
---

Interview scorecard block was booked at 30 min and overlapped another event; the requested length was 45 min.

**What happened:** The scorecard block was created 30 min long, in a slot that overlapped an existing meeting the user had not answered. The user had asked for 45 min.

**Root cause:** The scan reference and the calling skill both hard-code a 30-min block and "first free slot of at least 30 minutes". Free-slot detection treated unanswered (no-RSVP) events as free, and nothing re-read the calendar after creation to confirm duration and overlap.

**Suggested fix:** Default the scorecard to 45 min (a user-stated duration always wins). Count every event on the calendar as busy, including unanswered or tentative ones. Scan forward in 15-min steps for a fully free window of the full duration. After `create_event`, re-list the day and verify start, end, duration, and zero overlap; fix or flag on mismatch. Update the calling skill's Stage 2c text to match.
