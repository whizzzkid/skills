---
skill: wk-ruby
date: 2026-08-10
type: correction
severity: low
verified-against-source: yes
---

Access a Ruby `MatchData` named capture with `match[:name]`, not `fetch`.

**What happened:** A lightweight validation command called `fetch` on `MatchData` and failed with
`undefined method 'fetch' for an instance of MatchData (NoMethodError)`.

**Root cause:** `MatchData` provides bracket access for named captures but does not implement `fetch`.

**Suggested fix:** Use `match[:capture_name]` after checking the match is non-nil when extracting named regex captures
in Ruby validation commands.
