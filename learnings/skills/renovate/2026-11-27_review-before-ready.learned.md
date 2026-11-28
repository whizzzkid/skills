---
skill: wk-renovate
date: 2026-11-27
type: gap
severity: medium
verified-against-source: n/a
---

The combined PR merged on green CI before the post-ready adversarial review could run.

**What happened:** The combined dependency PR was marked ready and set to auto-squash by the user within minutes of the
draft opening, and it merged as soon as CI went green. The adversarial review that Step 6 schedules after ready never
ran, even though the batch contained pre-1.0 minor bumps that count as majors.

**Root cause:** The skill orders review after mark-ready, which assumes the agent controls the merge. A user can
enable auto-merge on the draft, so the ready-then-review order leaves a window with no gate.

**Suggested fix:** When Step 4 finds any major-class change, run the adversarial review while the PR is still draft
(or before pushing) and record the verdict in the body, so a user-initiated merge never outruns the gate.
