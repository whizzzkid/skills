---
class: principle
---

**Rule** — Test-plan checkbox verification gates both PR description updates and merge/auto-merge enablement. An unchecked `- [ ]` item blocks the merge command, not just the description edit.

**Why** — When processing multiple PRs, the agent treated the test-plan checklist as cosmetic during the push-to-merge flow, merging PRs with unchecked items. The existing Phase 6 HARD RULE scoped verification to "before updating the PR description" but not to the merge gate, leaving a gap.

**Where** — `SKILL.md` → Phase 6 → HARD RULE (expanded to cover merge).
