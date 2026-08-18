---
skill: wk-workflow
date: 2026-08-17
type: correction
severity: medium
verified-against-source: n/a
---

Used raw `gh pr merge` instead of invoking wk-pr-merge skill

**What happened:** After user approved merging 3 PRs, the agent ran
`gh pr merge` directly instead of invoking `wk-pr-merge` via the Skill tool.
The merges succeeded but skipped the post-merge checklist: ticket transitions,
follow-up collection, worktree cleanup verification, and retro trigger. The user
caught it by asking whether wk-pr-merge had been run.

**Root cause:** The workflow's autonomy table covers "Ready to commit → invoke
wk-commit" and "Tests pass → invoke wk-pr" but does not have an explicit row for
"Merge approved → invoke wk-pr-merge". The agent treated merge as a raw shell
command rather than a skill-owned lifecycle event.

**Suggested fix:** Add an autonomy-table row to wk-workflow:
`| Ready to merge | Invoke wk-pr-merge | Run raw gh pr merge |`. The "skill
invocation is mandatory" rule already covers this, but an explicit row prevents
the pattern where the agent reaches for the CLI tool it knows how to use instead
of the skill that wraps it.
