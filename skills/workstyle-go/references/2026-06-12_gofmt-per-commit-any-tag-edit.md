---
class: principle
date: 2026-06-12
skill: wk-workstyle-go
---

- **Rule:** Run `gofmt -l` immediately before EVERY commit touching a `.go`
  file, regardless of edit type — adding, widening, OR removing a struct tag
  all shift alignment columns. The gate is per-commit, not per-session.
- **Why:** A clean gofmt check earlier in the session does not carry forward;
  a later tag-removal edit left trailing comments mis-aligned and CI failed.
- **Where:** Pre-Commit Gate — generalized the gate to per-commit + all tag
  edits (prior rule covered goimports after type widening only).
