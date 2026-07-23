---
skill: wk-pr-merge
date: 2026-07-22
type: gap
severity: medium
---

Step 2's `gh pr checks --json name,state,required` errors on `gh` versions whose `checks` schema has no `required` field.

**What happened:** Step 2's literal command `gh pr checks {number} --json name,state,required` failed with `Unknown JSON field: "required"`. The CI-green gate had no fallback, so verification stalled on a command error rather than a check result.

**Root cause:** The `required` field on `gh pr checks --json` is version-dependent — older/other `gh` builds do not expose it. The skill hard-codes it as the sole CI-verification path with no version guard or alternate route.

**Suggested fix:** In Step 2, treat the `required` field as best-effort. On `Unknown JSON field`, fall back to (a) `gh api repos/{owner}/{repo}/commits/{head_sha}/check-runs` for per-check conclusions, plus (b) a direct CI-provider query (e.g. `bk build view`) against the current `{head_sha}` to confirm green. Never let a `--json` field error block the gate — degrade to an alternate source.
