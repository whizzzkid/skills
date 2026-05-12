---
date: 2026-05-12
slug: grep-qv-false-positive
---

- **Rule:** Never use `grep -qv 'pattern'` as a negative assertion; use `! grep -q 'pattern'` instead.
- **Why:** `-v` inverts per-line matching, so `grep -qv` exits 0 whenever **any** line in the input does not match — almost always true for multi-line output, making the assertion useless.
- **Where:** Phase 3 → "Shell-script structure tests" sub-section, item 3.
