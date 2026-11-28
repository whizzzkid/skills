---
class: principle
skill: wk-sitrep
date: 2026-11-27
severity: low
---

# Compute epoch window bounds; never hand-type them

**Rule** — Compute every Unix-epoch window bound in the shell from the ISO date and the user's zone (`TZ` set,
`date -j -f`) and paste the printed value into briefs. Tell each agent to verify one bound against a known message
timestamp.

**Why** — Hand-composed epoch seconds for a closed-day window put the lower bound at 01:00 local on the next day; a
timezone/DST-style offset slipped in and only an agent's cross-check caught it.

**Where** — `SKILL.md` Stage 0.5; `references/missed-end-rollover.md` → Shared gather.
