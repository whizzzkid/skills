---
class: principle
---

- **Rule:** Emit adversarial-review learnings in Step 9.4, **before** the Step 9.5 CI wait. CI wait blocks foreground work; tasks scheduled after a background watch are dead time. Each post-CI loop cycle re-runs Step 9.4 for that cycle's new findings before the next wait.
- **Why:** Claude does not continue work while a background CI watch is pending. Parking the learnings emission after the wait extends the session needlessly; the data needed for emission (resolved comments) is already complete after Step 8's push. Front-loading shifts the work into active time.
- **Where:** Step 9.4 (new) "Capture Adversarial-Review Learnings" inserted between Step 9 and Step 9.5. Former Step 11 body removed; former Step 12 (Session Retro) renumbered to Step 11. Quick Reference + README updated.
