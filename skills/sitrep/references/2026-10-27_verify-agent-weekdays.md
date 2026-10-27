---
class: principle
source: learnings/skills/sitrep/2026-10-27_verify-agent-weekdays.learned.md
date: 2026-10-27
skill: wk-sitrep
---

**Rule** — The orchestrator recomputes every day-of-week label from its ISO date before writing it to the page,
snapshot, or standup. When the source or a gathering agent disagrees, write the computed day and note the correction.
Gathering agents return ISO dates and pass any source weekday through as `source_weekday`, never as fact.

**Why** — A chat-derived deadline arrived labelled "Fri" on a date that is a Saturday; agents copy weekday wording
from the source message, and the contract asked for dates without asking anyone to check the weekday. A false
day-of-week on the page reads as authoritative, and the user tolerates none.

**Where** — `SKILL.md` → Core hard rules (*recompute every weekday from its date*); `subagent-contract.md` → ISO-date
line.
