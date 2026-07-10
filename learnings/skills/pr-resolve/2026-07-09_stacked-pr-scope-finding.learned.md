---
skill: wk-pr-resolve
date: 2026-07-09
type: correction
severity: low
---

A bot "docs claim X is gated but the code doesn't gate it" finding on a stacked PR has two remedies — apply the gate, or fix the wording — and the wording fix is correct when the next stacked PR owns the gate.

**What happened:** A config-safety finding flagged that docs implied the Karafka UIs were protected while the code left them unmounted. The user interrupted to clarify that gating them belongs to the next stacked PR, so the remedy here was to reword the docs to future tense — not to pull the sibling PR's scope forward.

**Root cause:** The skill treats such a finding as a normal fix without first checking whether the "missing" behavior is deliberately deferred to a stacked/sibling PR. Pulling that scope in would break the stacking plan and bloat the current PR.

**Suggested fix:** When a finding says docs/comments describe behavior the diff doesn't implement, first check the PR body/stack section for a stacked or follow-up PR that owns that behavior; if one exists, default to correcting the wording to future tense (naming the follow-up PR) rather than implementing the deferred change in this PR.
