---
class: principle
source: learnings/skills/workflow/2026-08-13_verify-fix-before-shipping.md
date: 2026-08-13
---

## Fix-symptom match — verify root cause before shipping

A fix must target the exact user-reported symptom, not a plausible-but-different
failure mode discovered during investigation.

**Failure mode:** agent diagnoses a real but incidental issue, ships a fix that
changes nothing observable for the user, and receives "I don't see any
difference" feedback — wasted round-trip.

**Guard:** (1) before coding, confirm the diagnosed root cause explains the
specific symptom the user described. (2) When multiple hypotheses exist, test
the simplest first. (3) When in-agent testing is impossible, state explicitly
what the user should observe differently and why.

**Landed in:** `SKILL.md` Phase 3 Verification → "Fix-symptom match" bullet.
