---
skill: wk-gh
date: 2026-06-25
type: correction
severity: medium
---

Always resolve repo name via `gh repo view --json name` before GraphQL calls — URL slug ≠ repo name.

**What happened:** GraphQL query used the hyphenated form of a repo name (as seen in URLs and `$GITHUB_ORG`-scoped searches) instead of the actual repo name which uses underscores. This caused a `NOT_FOUND` error that required a recovery step.

**Root cause:** GitHub URLs normalize underscores to hyphens in repo paths, but the GraphQL API requires the exact repo name as stored (with underscores). The agent assumed the URL form was authoritative.

**Suggested fix:** Before any GraphQL call using `$owner` and `$repo`, always resolve the exact repo name via `gh repo view --json owner,name --jq '{owner: .owner.login, name: .name}'`. Never derive `$repo` from a URL slug or `$GITHUB_ORG` context — they may differ. This is especially important for repos whose names contain underscores (common in snake_case naming conventions).
