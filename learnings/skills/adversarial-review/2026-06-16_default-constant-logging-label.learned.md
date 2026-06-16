---
skill: wk-adversarial-review
date: 2026-06-16
type: gap
severity: medium
---

Grep display-label and logging functions when changing a default-constant value.

**What happened:** A "fallback model" constant was changed from an implicit CLI default to an explicit value. A logging helper that formats the model label still returned the old string literal ("<cli-default>") for the empty-model path, so logs would show the wrong model name at runtime. Adversarial review caught it.

**Root cause:** The sweep searched for call sites of the changed constant but did not search for display-label or logging functions that hard-coded a string representing the old default behavior.

**Suggested fix:** When the diff introduces or renames a fallback constant, add a sweep: grep all files for string literals that describe the old default behavior (e.g. "cli-default", "no model", "default model") and verify each is updated or intentionally kept.
