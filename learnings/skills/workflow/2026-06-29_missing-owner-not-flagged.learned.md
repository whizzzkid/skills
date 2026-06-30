---
skill: wk-workflow
date: 2026-06-29
type: gap
severity: medium
---

Ask for owner when adding a CSV row if all existing rows have one

**What happened:** Added a new row to a CSV where every other row had an owner column populated. Ran the upsert without an `--owner` flag, leaving the field blank. User had to catch it.

**Root cause:** No check was done to see whether the owner field was conventionally required. The upsert tool accepted the omission silently.

**Suggested fix:** Before running an insert/upsert into a structured data file, scan nearby rows for required-by-convention fields (e.g., owner, comment). If all existing rows have a field and the new row would leave it blank, ask the user to supply it before proceeding.
