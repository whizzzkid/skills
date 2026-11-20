---
skill: wk-self-review
date: 2026-11-20
type: correction
severity: medium
verified-against-source: n/a
---

The agent sent the payload Edit and the review POST as parallel calls, so the POST could have read the unedited file.

**What happened:** An anchor-line fix to the self-review JSON went out in the same batch as the
`gh api .../reviews --input` POST. It only came out right because the Edit finished first. The agent then had to
re-fetch the staged comments to confirm the positions.

**Root cause:** The two calls depended on each other (the POST reads the file the Edit writes), but were treated as
independent.

**Suggested fix:** Step 4: payload edits and the POST are sequential. Make the last Edit/Write in one turn, then POST
in the next.
