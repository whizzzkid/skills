---
skill: wk-skill
date: 2026-06-04
type: gap
severity: medium
---

When a new skill supersedes existing skills, audit the superseded skills for feature parity before shipping.

**What happened:** A new skill was built to replace two existing rituals "except the HTML part." Several non-HTML features (standup snippet, QPR season banner, end-of-day learnings distillation, snapshot idempotency) were missing from the first version and surfaced one-by-one across multiple real runs, each requiring a follow-up sharpen pass.

**Root cause:** wk-skill has no step that, when the user frames a new skill as replacing/superseding existing ones, enumerates the superseded skills' features and checks each against the new skill before declaring it done.

**Suggested fix:** Add a parity-audit step to wk-skill triggered by supersede phrasing ("replaces X", "instead of X", "deprecate X once done"). Read each named skill's SKILL.md, extract its feature/stage list, and confirm the new skill covers each (or records an explicit, intentional exclusion). Also flag any reference coupling — if the new skill links to the superseded one as a spec source, deprecation must keep the file, not delete it.
