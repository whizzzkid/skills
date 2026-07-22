---
skill: wk-pr-merge
date: 2026-07-22
type: gap
severity: medium
---

Minor findings flow unclear on merge timing

**What happened:** Step 4 Minor findings gate says "propose one Jira ticket per finding... ask the user for the epic/parent, file it, then resolve each thread... User declines filing → leave the thread open and proceed anyway." The flow reads as: propose → ask → file → resolve → proceed, but when the user signals readiness to merge, this multi-step sequence delays the merge and blocks on follow-up decisions unrelated to merge readiness.

**Root cause:** The skill's Step 4 Minor-findings flow doesn't distinguish between "merge-gate" and "follow-up-gate." Minor findings never block merge (per the rule "Minor threads must not block a merge-ready PR"), but the instructional flow reads as if the ask-and-file steps are gating the merge, not just follow-ups.

**Suggested fix:** Clarify Step 4 Minor findings flow: "Do not block merge. Offer to file follow-up Jira/GitHub tickets post-merge in Step 8 output instead of pre-merge. Only ask for epic/parent if the user accepts the offer." This separates merge gating (no gate for Minor) from post-merge follow-ups.

