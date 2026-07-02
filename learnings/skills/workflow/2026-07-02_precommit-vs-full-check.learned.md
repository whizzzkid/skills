---
skill: wk-workflow
date: 2026-07-02
type: gap
severity: medium
---

"Lint clean" was claimed from a pre-commit hook that lints a narrower file set than the full CI check.

**What happened:** A pre-commit hook globbed only `*.sh`, so a formatter never ran against `.bats` files; the full CI-mirroring check does lint them and later flagged the drift.

**Root cause:** Trusting the pre-commit hook as equivalent to the full check, when the hook covers a narrower file set by design.

**Suggested fix:** Before claiming lint/format clean, run the full CI-mirroring check (not just the pre-commit hook). Treat the hook as a fast subset, never as the authoritative gate.
