---
skill: wk-workflow
date: 2026-06-01
type: gap
severity: high
---

wk-workflow must invoke wk-workstyle before committing any code change.

**What happened:** Code was committed and pushed to a PR with variable names that violated semantic naming conventions (`nitpicks` used for a bucket of minor+info findings — not accurate, since minor issues are not necessarily nitpicky). The naming problem was caught by a human reviewer on the PR, not by the agent during authorship.

**Root cause:** wk-workflow's implementation phase does not explicitly require invoking wk-workstyle as a gate before committing. The skill describes wk-workstyle as "auto-invoked whenever the agent writes, edits, or refactors code" but that description lives in wk-workstyle's own frontmatter — wk-workflow has no explicit "invoke wk-workstyle" step that enforces it as a hard requirement.

**Suggested fix:** Add an explicit mandatory step in wk-workflow's implementation phase: before every `wk-commit` invocation, run `Skill(wk-workstyle)` to gate the commit. The step should be labeled as non-skippable — the same way the adversarial-review gate is framed before push. "Auto-invoked" in a skill description is aspirational; a mandatory step in the calling skill is enforceable.
