---
class: principle
date: 2026-06-22
---

**Rule.** Starting work on a ticket is one atomic, self-healing "claim":
assign-to-user + In Progress + active sprint + a start comment fire together on
*any* detected development intent (edit/commit/PR work), not only the literal
first commit. If the claim has not completed this branch, run the whole thing
now — including mid-branch joins and resumed sessions. Post a factual progress
comment (`addCommentToJiraIssue`) at each lifecycle change (claim / PR opened /
merged), auto and confirmation-exempt like auto-assign.

**Why.** Field report: the skill was not assigning the ticket to the user, not
moving it to the active sprint, and never commenting on progress. Root causes:
(1) Stage 2's trigger was scoped to "first edit / first commit on a fresh
branch" — a signal that is often never observed (mid-branch join, edit before
commit), so assign + sprint silently never ran; (2) the skill had **no**
comment-posting behavior at all — a genuine gap, ticket states advanced with no
narrative.

**Where.** wk-jira Stage 2 (claim HARD RULE + broadened trigger), new Progress
comment subroutine, Stage 3 PR-opened comment, Stage 5 merged comment, Stage 0
tool list (`addCommentToJiraIssue`), Manual-operations table (auto-comment
exemption).

**Escalation.** Re-violation of the existing assign + active-sprint rules
(prior reference `2026-06-03_assign-active-sprint.md`). Notch bump: prose rule →
restructured into a HARD RULE atomic claim that is structurally hard to skip
(all four parts named as one unit, self-healing on any dev intent).
