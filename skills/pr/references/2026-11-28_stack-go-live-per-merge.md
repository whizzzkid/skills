---
class: principle
---

# Derive a stack's go-live steps per merge, not per stack

**Rule** — When asked for go-live or rollout steps on a stacked change, read each layer's diff and list what that
merge makes live (a code path wired, a flag read, a job scheduled). Attach every prerequisite — flag targeting rule,
secret, config value, migration — to the first merge whose code reads it, not to the front of the list.

**Why** — Early layers of a stack often only add or initialize a dependency; the user-visible wiring lands in a later
layer. A sequence written as if the whole stack lands at once front-loads prerequisites nothing reads yet and misstates
what each merge exposes, so the user has to correct the order.

**Where** — `SKILL.md` → Step 2 → Stacking → *Go-live steps for a stack*; per-layer `## Rollout` note scoping in
`references/pr-body-extras.md`. Secret provisioning routes to `wk-plan`'s secret-ownership probe.
