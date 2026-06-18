---
skill: wk-adversarial-review
date: 2026-06-18
type: gap
severity: medium
---

Dead production code: validation helper replaced by inline per-field logic but not deleted

**What happened:** A validation helper (`validateClassification`) was refactored away — the live path switched to per-field inline sanitization inside `extractClassificationJSON` — but the helper was not deleted. Tests continued asserting the helper's behavior, not the live path. The adversarial review caught this; the live validation contract was untested.

**Root cause:** The inline refactor (per-field validation replacing all-or-nothing drop) created two divergent implementations. The helper was not swept for callers; tests were not updated to target the live path. Future drift between the two implementations would be silent.

**Suggested fix:** After any refactor that moves validation logic inline, add a sweep step: grep the helper by name in non-test files; zero matches → it is dead code. Delete it and rewrite its tests against the live caller. Add this as a step in the review checklist: "for each new helper, confirm it has at least one non-test caller."
