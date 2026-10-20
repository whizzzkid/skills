---
skill: wk-cal
date: 2026-10-20
type: gap
severity: low
verified-against-source: yes
---

The calendar connector's create and free/busy tools use different parameter names than the skill documents.

**What happened:** `create_event` rejected `start`/`end` objects (requires flat `start_time`/`end_time` ISO strings with offset) and `get_free_busy` rejected `items` (requires `calendar_ids`).

**Root cause:** The skill's examples mirror the raw Google API shape, not the connector's schema.

**Suggested fix:** Update the examples to `start_time`, `end_time`, `calendar_ids`; prefer `list_events` over free/busy for a single calendar.
