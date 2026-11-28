---
skill: wk-workflow
date: 2026-11-27
type: correction
severity: low
verified-against-source: n/a
---

Grep your own shipped artifacts before claiming they lack something.

**What happened:** The agent told the user an ADR it had written did not mention an alternative and proposed adding
it; when opening the file to edit, the ADR already named and rejected that alternative.

**Root cause:** The claim came from memory of the session summary, not from the file.

**Suggested fix:** Before asserting a gap in docs or code (yours or anyone's), grep the artifact in the same turn and
quote the line, or state the gap as unverified.
