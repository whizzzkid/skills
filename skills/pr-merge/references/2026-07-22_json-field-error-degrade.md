---
class: principle
---

**Rule** — A `gh pr checks --json` field is version-dependent; a field error
(`Unknown JSON field: "required"`) must degrade to an alternate source, never
block the CI-green gate. Fall back to the check-runs API
(`gh api repos/{owner}/{repo}/commits/{head_sha}/check-runs`) for per-check
conclusions and cross-verify with the CI provider's own CLI when available.

**Why** — Older/other `gh` builds do not expose every `--json` field. Hard-coding
one as the sole verification path stalls the gate on a tool error instead of a
check result.

**Where** — wk-pr-merge Step 2 (Verify CI is green).
