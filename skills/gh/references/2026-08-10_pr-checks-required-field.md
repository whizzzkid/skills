---
class: one-off
date: 2026-08-10
skill: wk-gh
---

# gh pr checks --json may not expose `required` field

- **Scenario:** A required-check query failed with `Unknown JSON field: "required"`
  because the installed CLI exposed `bucket`, `state`, and related fields but not
  `required`.
- **Symptom:** Workflow assumed a newer `gh pr checks` JSON schema without checking
  field availability.
- **Fix:** Probe `gh pr checks --json` field availability first; when `required` is
  unavailable, derive required contexts from the active repository ruleset and
  compare with the current head's check rollup. The skill's "A required context
  can be absent" section already covers the ruleset path.
- **Why not promoted:** The existing ruleset-based required-context resolution in
  SKILL.md is the authoritative path. Body at ceiling.
