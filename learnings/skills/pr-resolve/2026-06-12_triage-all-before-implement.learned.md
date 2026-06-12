---
skill: wk-pr-resolve
date: 2026-06-11
type: correction
severity: medium
---

Triage all comments before implementing any fix.

**What happened:** After the user chose `(a)` for Comment 1, the agent immediately began reading files and implementing the fix for Comment 2 (a significant refactor). The user interrupted: "wait we didn't triage the other comments." Two comments (3 and 4) had not been presented yet.

**Root cause:** The one-at-a-time presentation rule was interpreted as "present → get decision → implement → present next." The correct interpretation is "present all → get all decisions → implement all." Implement only after the full triage pass is complete.

**Suggested fix:** After presenting the final comment in the triage pass and collecting all decisions, THEN begin implementing fixes in sequence. Never start implementation mid-triage. Add a step between Step 4 (generate suggestions) and Step 6 (implement) that explicitly confirms all comments have received a decision before the first commit.
