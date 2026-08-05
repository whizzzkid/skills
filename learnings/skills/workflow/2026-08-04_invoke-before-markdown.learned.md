---
skill: wk-workflow
date: 2026-08-04
type: correction
severity: low
verified-against-source: yes
---

Invoke format-specific skills before the first matching edit.

**What happened:** A Markdown documentation edit was applied before the Markdown skill was invoked,
then audited immediately afterward.

**Root cause:** The workflow planned the documentation sync but did not place the format-specific
skill invocation before the edit action.

**Suggested fix:** Make the implementation pre-flight enumerate changed file types and invoke their
format-specific skills before the first patch.
