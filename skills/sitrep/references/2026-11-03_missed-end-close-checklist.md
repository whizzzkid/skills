---
class: one-off
---

# Missed-end close checklist

- **Scenario:** `start` found the prior live page with no close marker, and the user had ticked spans in the browser
  since its last commit, so the full `end` flow ran first.
- **Symptom:** The rollover needed two unplanned recoveries: preserving the user-ticked spans through the close, and
  re-issuing tool calls the auto-mode gate rejected when batched in one response.
- **Fix:** Ordered close checklist in [`missed-end-rollover.md`](missed-end-rollover.md) (ticked-span count before
  any write, asserted after the snapshot); skipped copy-click verification is stated, per
  [`standup-copy-block.md`](standup-copy-block.md). The batched-call rejection is tool mechanics, folded into
  [`wk-env`](../../env/README.md) Step 3.6 as the sibling variant.
- **Why not promoted:** The rollover procedure was already correct; the checklist only orders existing steps and adds
  one count assertion, which belongs in the procedure reference, not the always-loaded body.
