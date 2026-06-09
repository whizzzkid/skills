---
skill: wk-pr-takeover
date: 2026-06-09
type: gap
severity: medium
---

Infer target PR from current branch when no argument is provided.

**What happened:** Skill prompted the user for a PR number/URL even though the current branch already had an associated PR discoverable via `gh pr view`.

**Root cause:** Step 1 only handles explicit arguments; no branch-inference fallback exists before the user-prompt path.

**Suggested fix:** Before asking the user, run `gh pr view --json number,title 2>/dev/null` on the current branch. If a PR is found, use it and surface it to the user ("Taking over PR #N on the current branch — continue?"). Only fall through to the explicit prompt when no PR is found.
