---
skill: wk-pr
date: 2026-07-20
type: correction
severity: medium
---

Agent over-deferred small, correct automated-bot review findings as "scope creep"; the user twice redirected toward fixing more.

**What happened:** On the automated-review-feedback step, the agent presented each round of bot findings with a recommendation to fix one or two and defer the rest as out-of-scope. The user overrode both times — first confirming a fix ({user} replied "fix 1"), then instructing "fix all" against the agent's proposal to defer three test-scope findings.

**Root cause:** The triage step biases toward deferral to keep the PR small, but a finding that is small (<10-line fix) and correct is cheaper to fix in-round than to defer — deferral creates a follow-up round the reviewer must re-approve. The skill frames deferral as the safe default; for cheap correct findings it is the costly one.

**Suggested fix:** In the automated-feedback triage step, default to fixing any bot finding whose fix is small and whose premise is correct, rather than proposing to defer it. Reserve "defer" for findings that are genuinely large, contested, or out of the PR's stated scope — and when unsure between fix and defer on a small correct finding, fix it. Present the triage as "fixing these, deferring these because X", not "recommend fixing one, defer the rest".
