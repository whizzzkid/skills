---
class: principle
source: learnings/retrospect/2026-08-20_session-2.md
date: 2026-08-20
skill: wk-renovate
---

## Principle

GitHub's `Closes #N` keyword auto-closes both issues and pull requests on
merge. The original HARD RULE claiming otherwise was incorrect and never
field-verified.

## Evidence

Session merged a combined PR with `Closes #N` for five Dependabot PRs. All
five auto-closed on merge without manual `gh pr close`.

## Resolution

Reversed the HARD RULE. Updated PR body template to use `Closes #N` instead of
`Supersedes`. Step 7 now handles stragglers only.
