---
skill: wk-workflow
date: 2026-11-26
type: correction
severity: medium
verified-against-source: n/a
---

After a visual fix, every screenshot the PR references must be retaken, not just the overview shots.

**What happened:** A follow-up commit changed the visual result (control widths). The agent retook only two full-page
shots and left the PR body pointing at four state screenshots (hover, post-click) captured before the fix. When the user
opened them, the widths were unequal and the fix looked like a failure. The agent had disclosed the staleness in prose,
but the artifacts themselves contradicted the claim.

**Root cause:** Screenshots were treated as one-time evidence attached to the first pass, not as artifacts that have to
match HEAD. Nothing tied each listed screenshot to the commit it shows.

**Suggested fix:** In Phase 3.6, after any commit that changes rendered output, re-run the full capture script for
every screenshot the PR body lists, overwriting the files. Delete superseded captures, and never list a capture older
than the last visual commit. Keep the capture sequence as one re-runnable script, so a re-shoot is one call rather than
a hand-picked subset.
