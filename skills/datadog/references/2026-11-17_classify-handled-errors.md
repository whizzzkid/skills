---
class: principle
---

- **Rule** — Before designing a fix for an alerting error, classify it handled vs unhandled from the span's
  error-handling tag and the sibling spans in the same trace.
- **Why** — A session's alerting error looked like an outage; the span tag and sibling spans showed a handled error
  from a known race, reframing the work from "outage" to "telemetry noise". Captured from a session retrospect's
  "What worked" list.
- **Where** — `SKILL.md` Logs section, beside the causal-claim HARD RULE.
