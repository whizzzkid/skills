---
class: one-off
outcome: already-covered — no skill edit
source: learnings/skills/retro/2026-08-18_compaction-recovery.md
date: 2026-08-18
severity: low
---

## Compaction recovery behaved as specified — recorded, not folded

A session resumed from a compaction summary carrying a drafted retro entry with two
"what could've been better" bullets, one of which had already produced its `wk-learn`
call. The agent treated the summary as the source of truth, did not re-derive the
retro or rewrite the retrospect log, and made only the single outstanding call.

**Classification:** `already-covered`. The learning is a positive confirmation and
says so in its own root-cause field; it asks for no change.

**Coverage, matched rule by rule** — all in `skills/retro/SKILL.md`:

- Resume from a compaction summary mentioning an in-progress retro → line 284–285.
- Verify which bullets already got their call and make only the missing ones, before
  any other work → line 286.
- Treat the summary as the source of truth for which skills still need a call,
  rather than re-deriving the retro → line 287–288.
- One call per affected skill, not one per session → line 283.

**No escalation.** The re-violation ladder does not apply: this is not a repeat of a
failure but same-session evidence that the rule fired correctly, which the escalation
exception treats as proof the rule works. Notching it would harden text that is
already producing the intended behavior.

**Why this record exists at all:** a positive confirmation is worth keeping so a later
pass does not read the untouched rule as unverified and "strengthen" it. The rule's
minimal-resume behavior is deliberate — re-running the full retro would be the
regression.
