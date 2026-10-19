---
skill: wk-sitrep
date: 2026-10-19
type: gap
severity: medium
verified-against-source: n/a
---

Roster still named a meeting-notes connector the user had retired, so every run aborted until a per-run waiver.

**What happened:** The skill's agent roster, ToolSearch hints and allowed-tools list named a meeting-notes connector the
user no longer uses. Because required connectors derive from the roster, the run stopped before gathering and needed a
user decision to continue; the replacement connector was already available.

**Root cause:** The roster is hard-coded in the skill, so a tool migration silently turns a retired connector into a
mandatory one. A per-run waiver does not fix it; it recurs on the next run.

**Suggested fix:** On a missing-connector abort, check whether an available connector covers the same domain and, if
the user confirms a migration, edit the roster (name, ToolSearch hint, allowed-tools, requirements list) instead of
waiving. Offer that option alongside "waive once" / "waive always".
