---
skill: wk-arch-review
date: 2026-10-16
type: correction
severity: medium
verified-against-source: n/a
---

When a spec is built from meeting notes, use the notes only to find claims, never as citations or quotes.

**What happened:** The user stepped in mid-task and said not to quote anyone from the meeting notes, and to treat them
only as leads to validate.

**Root cause:** The authoring flow had no rule against attributing statements to people or linking private meeting
notes in a shared design doc.

**Suggested fix:** In WRITE mode, require that every claim sourced from a meeting be re-anchored to a primary source
(code, vendor docs, tickets) before it goes in the doc. Never name speakers and never link 1:1 notes.
