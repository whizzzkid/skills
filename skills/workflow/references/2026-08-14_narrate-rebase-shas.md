---
class: principle
---

**Rule** — After any branch-rewriting operation (`git pull --rebase`, `git rebase`,
merge with remote), narrate before/after SHAs and a one-line summary so the user
has an audit trail without inspecting `git log` themselves.

**Why** — A rebase/push sequence that produces no visible evidence of what was
preserved causes the user to believe work was lost, even when it was not. The
concern is avoidable by printing the state change.

**Where** — `SKILL.md` Phase 2: Implement, bullet after the per-step commit loop.
