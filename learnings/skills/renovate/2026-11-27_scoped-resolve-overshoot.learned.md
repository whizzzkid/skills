---
skill: wk-renovate
date: 2026-11-27
type: surprise
severity: low
verified-against-source: yes
---

A scoped conservative update resolves to the newest release, not the advertised version, for most bumped packages.

**What happened:** Re-resolving each bump with `bundle lock --conservative --update <name>` moved four of seven
packages past the version the Dependabot PR advertised, because newer releases had shipped since the PR opened. Each
was caught only by reading the lockfile diff, then edited back and validated with `bundle install`.

**Root cause:** The scoped update only limits which packages may move; it applies no upper bound, so it picks the
latest allowed version. Confirmed by diffing the lockfile after every resolve.

**Suggested fix:** In Step 3, make the loop explicit: resolve, diff, edit the lock line back to the advertised
version, run install, and only then commit. Do not treat the resolve output as final.
