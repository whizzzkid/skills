---
skill: wk-workflow
date: 2026-05-13
type: correction
severity: medium
---

Resolve stale self-review comments whenever the implementation approach changes significantly.

**What happened:** After pivoting from a sentinel-file approach to `buildkite-agent step get "outcome"`, the PR description was updated but the pending self-review comments (which explained the sentinel rationale) were left untouched and became misleading.

**Root cause:** wk-commit's PR Sync rule covers title/body drift but not self-review comment drift. On an approach pivot, self-review comments referencing the old design are just as stale as a stale PR body.

**Suggested fix:** After any push that changes the implementation approach (not just polish), resolve pending self-review threads that reference the old design and post new ones for the new design via wk-self-review before returning control.
