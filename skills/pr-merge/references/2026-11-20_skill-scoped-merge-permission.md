---
class: principle
source: learnings/skills/pr-merge/2026-11-20_skill-scoped-merge-permission.learned.md
date: 2026-11-20
skill: wk-pr-merge
---

**Rule** — In the Step 6 permission preflight, offer the allow rule at a scope the user picks (this repo's
`.claude/settings.local.json` or user-wide) next to the manual-merge link. State that the skill's `allowed-tools`
grants nothing against the classifier and that no skill-scoped grant is verified. Never imply one exists, and never
offer the user-wide rule as the only fix.

**Why** — An auto-mode merge was denied as "merge without review". The preflight offered only a user-wide
`Bash(gh pr merge:*)` rule. The user wanted the permission tied to the skill and had assumed `allowed-tools: Bash`
already gave it. `allowed-tools` only skips permission prompts; the classifier is a separate layer (the two-layer
model is in `merge-edge-cases.md`, but only on the post-denial path).

**Classification** — `partial`: the preflight (installed 2026-11-19) and the post-denial two-layer explanation
(installed 2026-07-20) stand. Neither offered a scope choice or corrected the `allowed-tools` assumption before the
call.

**Rejected suggestion** — offering a skill-gated PreToolUse hook (a head-SHA marker written after the checklist
passes) as a skill-scoped grant. No live test shows that a hook `allow` decision skips the auto-mode classifier for
Bash, and host documentation suggests it does not. Revisit only after a live auto-mode test proves it. Until then,
naming it as a fix would repeat the false assumption this learning reports.

**Where** — `SKILL.md` → Step 6 (permission preflight bullet and its sub-bullet); README Noteworthy.
