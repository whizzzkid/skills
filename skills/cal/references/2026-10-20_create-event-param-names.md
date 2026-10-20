---
class: one-off
source: learnings/skills/cal/2026-10-20_create-event-param-names.learned.md
date: 2026-10-20
skill: wk-cal
---

**Scenario** — Creating an event and checking free/busy through the calendar connector using the skill's examples.

**Symptom** — `create_event` rejected nested `start`/`end` objects; `get_free_busy` rejected `items`.

**Fix** — Connector schema (verified from the tool definitions): `create_event` takes flat `start_time` / `end_time`
ISO 8601 strings plus optional `time_zone`, attendees as email strings; `get_free_busy` takes `calendar_ids` (string
list), `time_min`, `time_max`. Single calendar → `list_events`. Examples in `SKILL.md` corrected.

**Why not promoted** — A schema correction for one connector; the examples now carry it, no new rule needed.
