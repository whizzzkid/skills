---
skill: wk-gh
date: 2026-11-03
type: correction
severity: high
verified-against-source: yes
---

Verify which statuses are required via the branch rules API before claiming a red build cannot block a PR.

**What happened:** A fix kept `exit 1` on an advisory failure path, justified by the claim that a red build posts nothing to the target PR. The build's own commit status was a required check on the repo's default branch, so the claim was false for that repo's own PRs and the fix could still block a merge. An independent verifier caught it; the PR body and a code comment had already shipped the wrong claim.

**Root cause:** The claim was inferred from the pipeline config (no notify/status step) without reading the branch ruleset, which is where required statuses live.

**Suggested fix:** Before any reasoning of the form "this status/check can't block merge", run `gh api repos/{owner}/{repo}/rules/branches/{branch}` (and branch protection) and cite the required-status list.
