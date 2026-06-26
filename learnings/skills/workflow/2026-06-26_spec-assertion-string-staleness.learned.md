---
skill: wk-workflow
date: 2026-06-26
type: gap
severity: low
---

When reformatting a user-facing string, audit spec assertion literals for the old value before committing.

**What happened:** A UI-facing string (artifact download link format) was changed from `[Download foo.json]` to `[foo.json]`. Existing negative-assertion specs used the old literal as the match string, so they continued to pass — but for the wrong reason; they no longer guarded against the text they were originally testing for.

**Root cause:** The workflow step for "update specs to match implementation" focused on positive assertions but didn't prompt a grep for the old literal in negative assertions (`not_to include`). Negative assertions with stale match strings pass trivially and silently lose coverage.

**Suggested fix:** After any string rename or format change, grep the entire spec file for the old literal string before committing; update both positive `include` and negative `not_to include` assertions that reference it.
