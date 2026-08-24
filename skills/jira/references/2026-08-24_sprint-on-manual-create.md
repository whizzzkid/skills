---
class: principle
---

**Rule** — After `createJiraIssue`, invoke the Active-sprint assignment subroutine on each newly created issue. An issue created without a sprint assignment lands in the backlog — invisible on the sprint board, absent from velocity tracking.

**Why** — The subroutine existed for claim (Stage 2) and review (Stage 4) transitions but was not chained to the manual issue-creation path. Sprint assignment is a board-level field that defaults to null on creation.

**Where** — `SKILL.md` → Manual ticket operations, bullet after the confirmation table.
