---
skill: wk-pr-merge
date: 2026-11-26
type: gap
severity: low
verified-against-source: yes
---

Step 7 points at a ticket-transition reference file that does not exist in the skill's references directory.

**What happened:** On an already-merged PR the skill jumped to Step 7 and tried to read the referenced transition guide. The read failed with file-not-found, and the transition had to follow the Jira skill's rules instead.

**Root cause:** The reference is named in the skill body but was never shipped, or was moved or renamed.

**Suggested fix:** Add the file, or inline its content (fetch the issue, confirm the assignee, apply the Done transition, post a "Merged via" comment). Add a check that every referenced path in a skill resolves.
