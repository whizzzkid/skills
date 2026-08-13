---
class: principle
source: learnings/skills/workflow/2026-08-13_worktree-isolation-bash-blocked.md
date: 2026-08-13
skill: wk-workflow
---

## Principle

`isolation: "worktree"` agents have Bash, Grep, and Glob blocked by the harness sandbox.
The string-through-source detector is over-aggressive and rejects all shell invocations, even
trivial ones like `pwd`. Read/Edit/Write work normally.

When dispatching parallel agents that need shell (tests, lint, commit, push), either:
1. Skip worktree isolation entirely, or
2. Use a split-responsibility pattern: agents do Read/Edit/Write; the coordinator session
   handles all shell operations on the worktree paths after agents complete.

Monitor tool shares the same shell and may bypass the block, but this is unreliable and
Grep/Glob are also absent from isolated agents' tool registries.

## Folded Into

- `SKILL.md` — Autonomy Rules section: HARD RULE added for worktree-isolated agent Bash restriction
- `references/code-standards-extended.md` — base resolution recipe relocated from inline
- `references/environment-guardrails.md` — GemNotFound/mise recipe relocated from inline
