---
skill: wk-pr-review
date: 2026-07-20
type: correction
severity: high
---

The "invoke wk-arch-review" gate for spec/plan/ADR diffs must be a real Skill invocation, not a subagent substitute.

**What happened:** Reviewing a PR that added files under `docs/specs/` and `docs/plans/`, the agent recognized the wk-arch-review trigger but satisfied it by dispatching a general-purpose subagent with an arch-review-*style* prompt (spec-claim verification) instead of invoking the wk-arch-review skill. The user caught this and asked whether wk-arch-review had actually been run.

**Root cause:** The Phase 1 HARD RULE says a changed file matching `docs/(specs|adr|arch|design|rfc)/` "invokes wk-arch-review" — the agent treated "do arch-review-shaped investigation" as equivalent to "invoke the skill," collapsing a mandatory skill invocation into an ad-hoc subagent prompt. That skips the skill's Eight Lenses, its empirical-pass HARD RULE, and its findings-report contract.

**Suggested fix:** In wk-pr-review Phase 1, state that the arch-review trigger is satisfied ONLY by `Skill(wk-arch-review)` (or `Skill` tool) — a subagent with an arch-review-flavored prompt does NOT satisfy it. Delegating spec-claim verification to a subagent is fine as an ADDITION on top of the skill invocation, never a REPLACEMENT. Applies whenever the diff touches spec/adr/design/rfc/plan markdown, prose, or doc comments.
