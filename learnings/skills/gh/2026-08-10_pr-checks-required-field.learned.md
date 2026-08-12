---
skill: wk-gh
date: 2026-08-10
type: gap
severity: low
verified-against-source: yes
---

Probe `gh pr checks` JSON fields before relying on a `required` projection.

**What happened:** A required-check query failed with `Unknown JSON field: "required"` because the installed CLI
exposed `bucket`, `state`, and related fields but not `required`.

**Root cause:** The workflow assumed a newer or different `gh pr checks` JSON schema without checking the installed
CLI's available fields.

**Suggested fix:** Probe `gh pr checks --json` field availability first; when `required` is unavailable, derive
required contexts from the active repository ruleset and compare them with the current head's check rollup.
