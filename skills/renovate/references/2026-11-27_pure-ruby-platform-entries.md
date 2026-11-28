---
class: one-off
skill: wk-renovate
date: 2026-11-27
severity: low
---

# Dependabot adds unsuffixed native-gem platform entries

**Rule** — In the Step 3 lockfile diff, drop bare native-gem entries (no platform suffix) when the lock's `PLATFORMS`
names only arch/OS triples that already carry precompiled entries.

**Why** — Dependabot resolves on the generic `ruby` platform regardless of the lock's `PLATFORMS`; the scoped
re-resolve never introduces them. Folded as a one-line sub-bullet under the existing scope rule.

**Where** — `SKILL.md` → Step 3 HARD RULE (advertised bumps only).
