---
class: principle
skill: wk-workflow
---

**Rule:** Before inserting/upserting a row into a tabular or list-structured
data file (CSV, YAML/JSON list, fixtures), scan sibling rows for fields that are
populated by convention. If every existing row sets a field the new row would
leave blank, ask the user to supply it before writing.

**Why:** Insert/upsert tools accept the omission silently, so a missing
convention-required field (owner, comment, etc.) ships blank and the user has to
catch it after the fact.

**Where:** Phase 2 → Edit-scope pre-flights.
