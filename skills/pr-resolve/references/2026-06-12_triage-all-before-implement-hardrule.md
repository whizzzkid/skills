---
class: principle
date: 2026-06-12
skill: wk-pr-resolve
---

- **Rule:** An `(a)`/`(e)` reply records the fix into `fixes_to_apply`; it is
  not a go-signal. Implement only after every `judgment_required[]` item has a
  decision (Step 6, post "After all decisions collected" gate).
- **Why:** Agent repeatedly mis-reads a single `a` as a go-signal, refactors
  mid-triage, skips remaining comments, and fragments one resolution into
  multiple pushes — recurred across 3 learnings, user asked to harden.
- **Where:** Step 5 per-comment loop — new HARD RULE "triage every comment,
  THEN implement; never mid-triage", strengthening the prior already-covered
  guidance into an explicit gate.
- **Escalation:** Important (recurred 2026-06-12) — recurred again after the
  HARD RULE landed; bumped to notch 2 (`**Important:**`) per the wk-sharpen
  re-violation ladder. Next recurrence → "Very important".
