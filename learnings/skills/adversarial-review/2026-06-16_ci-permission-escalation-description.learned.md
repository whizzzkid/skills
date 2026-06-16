---
skill: wk-adversarial-review
date: 2026-06-16
type: gap
severity: high
---

CI permission-escalation PRs require Problem, Approach, and Testing sections in the description.

**What happened:** A PR that elevated a GitHub token's `contents` scope from `read` to `write` in a CI pipeline plugin carried only a placeholder description. An automated description-check flagged three Major findings: missing Problem context, missing Approach rationale, and title/diff mismatch.

**Root cause:** Security-sensitive changes (token scope, secret access, privilege escalation) are treated no differently from routine PRs during description authoring. The adversarial pass did not scan the PR body for required structural sections before declaring the description adequate.

**Suggested fix:** During adversarial review of any change touching token permissions, secret access, or privilege escalation, verify the PR body contains at minimum:
- `## Problem` — why the elevated scope is required
- `## Approach` — why alternatives (separate token, narrower scope, dedicated workflow) were ruled out
- `## Testing` — how the permission was exercised post-change

Detection sketch: `grep -E "## Problem|## Approach|## Testing" <pr_body>` — absence of any section on a security-sensitive diff should surface as a finding.
