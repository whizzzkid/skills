---
skill: wk-pr
date: 2026-06-02
type: correction
severity: high
---

wk-adversarial-review and wk-arch-review findings are mandatory to incorporate — never ask.

**What happened:** After running wk-arch-review on a spec, the agent asked the user
"want me to fold these findings into the spec?" The user had to explicitly say that
pre-flight reviews are mandatory and their findings should always be incorporated
without asking.

**Root cause:** The agent treated the arch-review as advisory and surfaced it as a
user-gated decision. But both wk-adversarial-review and wk-arch-review are mandatory
gates in the PR workflow — their findings are blockers/improvements to apply, not
options to consider.

**Suggested fix:** After any mandatory pre-flight review (wk-adversarial-review,
wk-arch-review), immediately incorporate all findings into the artifact under review —
fix blockers, fold in improvements, update the doc. Then commit. Never pause to ask
"should I incorporate these?" The only time to pause is if a finding is genuinely
ambiguous and requires a design decision only the user can make — in that case, present
the specific design question, not a blanket "should I update?".
