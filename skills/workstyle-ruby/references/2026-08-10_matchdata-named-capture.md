---
class: principle
date: 2026-08-10
skill: wk-workstyle-ruby
---

# MatchData uses bracket access, not fetch

- **Rule:** Access named captures via `match[:name]` after a nil check on the
  match. `MatchData` does not implement `fetch`; calling it raises
  `NoMethodError`.
- **Why:** A validation command called `fetch` on `MatchData` and failed at
  runtime.
- **Where:** Rules section — new MatchData bullet.
