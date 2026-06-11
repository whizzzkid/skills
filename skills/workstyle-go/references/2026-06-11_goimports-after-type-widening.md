---
class: principle
date: 2026-06-11
skill: wk-workstyle-go
---

- **Rule:** After renaming/widening a struct field's type, run `goimports`
  on the whole file; `gofmt` alone is insufficient.
- **Why:** `gofmt` realigns only the changed line; `goimports` recomputes
  the widest type across the struct and realigns every field's tag column.
  A format-on-save (`gofmt`) file is locally clean but fails CI `goimports -l`.
- **Where:** Pre-Commit Gate section.
