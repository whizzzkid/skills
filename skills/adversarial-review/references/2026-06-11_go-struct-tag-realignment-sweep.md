---
class: principle
date: 2026-06-11
skill: wk-adversarial-review
---

- **Rule:** Add a mechanical pre-push sweep — when a `.go` diff widens a
  struct field's type, run `goimports -l` on each touched file; non-empty
  output is a blocker.
- **Why:** `gofmt`/format-on-save realigns only the changed line; CI's
  `goimports -l` realigns every tag column and fails. Gap is invisible
  until CI. workstyle-go can only flag (Read/Grep) — adversarial-review
  runs the command, so the executable gate lives here.
- **Where:** Step 2 mechanical sweeps — new sweep 2.32.
