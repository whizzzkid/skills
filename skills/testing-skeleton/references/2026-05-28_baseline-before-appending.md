---
class: principle
date: 2026-05-28
source: ~/.claude/memory/feedback_baseline_test_before_appending.md
severity: medium
---

- **Rule:** Run an existing test file and confirm it passes before appending new tests; if it is already failing, fix the pre-existing failure or put the new tests in a standalone file.
- **Why:** Appending to a broken suite gives false confidence — the new tests appear to fail when the setup is broken, masking whether the new code is tested.
- **Where:** Five-rules block (added rule 6: "Baseline the suite before appending tests").
