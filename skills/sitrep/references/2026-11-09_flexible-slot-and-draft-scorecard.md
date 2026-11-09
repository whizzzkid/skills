---
class: principle
source: learnings/skills/sitrep/2026-11-09_habit-blocks-starve-scorecard.learned.md
date: 2026-11-09
skill: wk-sitrep
---

**Rule** — Stage 2c renders a no-free-slot scorecard as a warn item carrying `wk-cal`'s proposed flexible-block
placement (never a booking, per *no interactive triage*). A scorecard the hiring system holds in `draft` is
unsubmitted: render it as still owed, never done.

**Why** — A day packed with auto-scheduled habit blocks left only a bare warning with no placement to act on. The
terminal-state rule named only auto-action artifacts, so a user-saved draft scorecard had no rule keeping it open.

**Owner** — Placement logic lives in `wk-cal` (§Interview Prep Scan); this skill only renders it.

**Where** — `SKILL.md` → Stage 2c; `rendering-contract.md` → Terminal state rule.
