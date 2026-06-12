---
class: principle
date: 2026-06-12
skill: wk-concise
---

- **Rule:** Concise constrains internal reasoning, not just the visible reply.
  The per-turn hook reminder now carries a THINK-BRIEFLY / THINK-MINIMALLY
  clause: short deliberation, no re-deriving established facts, no plan
  narration, act when the path is clear.
- **Why:** The output caps alone left internal-monologue token cost high — the
  hook governed only the visible answer.
- **Where:** `hooks/concise-reminder.sh` (both brief + dense strings) and Mode
  Rules → "Reasoning brevity (both modes)". Hard lever remains the harness
  reasoning budget when the nudge is insufficient.
