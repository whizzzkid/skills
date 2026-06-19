---
skill: wk-pr
date: 2026-06-18
type: correction
severity: low
---

Do not re-run the adversarial gate before `gh pr ready` when the only commits since the last clear verdict are mechanical fixes to findings from that same verdict.

**What happened:** After receiving a clear adversarial verdict, agent made only mechanical commits that directly addressed blockers from that verdict (no new logic, no design changes). Before marking the PR ready, agent was about to invoke wk-adversarial-review again. User questioned why.

**Root cause:** wk-pr Step 5 says "invoke wk-adversarial-review one more time against PR HEAD before `gh pr ready`." The skill does not carve out an exception for the case where the only delta since the last clear verdict is mechanical application of that verdict's own findings.

**Suggested fix:** Add a scoped exception to the final gate: "If the only commits since the last `clear` verdict are direct mechanical responses to blockers from that verdict (no new logic, no refactors, no scope additions), the final gate may be skipped. Note the skip and the cleared-SHA in the PR comment. Any commit touching logic or adding new behavior still requires re-running the gate."
