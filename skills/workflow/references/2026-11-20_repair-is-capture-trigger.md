---
class: principle
skill: wk-workflow
date: 2026-11-20
---

# Re-violation: every repair of your own output is a capture trigger

- **Rule:** Treat every repair of your own output as a live-capture trigger: a corrected PR body, a re-armed or
  replaced watcher, a fallback route after an API error. Invoke `wk-learn` in the same response as the repair. The
  live-capture HARD RULE is escalated one rung, `CRITICAL` → `HIGH-PRIORITY`.
- **Why:** Four self-caught errors came up in one session; live capture fired for the first only, and retro
  reconstructed the other three (a guessed tracker host, a watch loop that never matched its build, an API 422).
  Each fix was applied at once and the repair felt routine, so the rule, installed well before the session, did not
  fire. One correct firing does not offset three misses, so this is escalation evidence, not positive steering.
- **Where:** `SKILL.md` → Mandatory Activation (live learning capture). Source: workflow learning and the 2026-11-21
  session-1 retrospect.
