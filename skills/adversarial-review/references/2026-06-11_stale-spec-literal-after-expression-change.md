---
class: principle
date: 2026-06-11
skill: wk-adversarial-review
severity: high
---

- **Rule:** Extend sweep 2.8's removed-term grep to `spec/`, `test/`, and
  `*_spec.*`/`*_test.*` globs for any removed/replaced string literal — a
  hit in a spec/test file is a blocker.
- **Why:** Structure tests assert exact source content (`include("…")`,
  `grep -q '…'`); a changed literal leaves a stale assertion that fails CI,
  and the docs-only grep never sees it.
- **Where:** Sweep 2.8 (Cross-doc enumeration sync), spec/test grep bullet.
