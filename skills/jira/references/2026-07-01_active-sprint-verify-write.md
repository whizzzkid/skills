---
class: principle
---

**Rule:** After the Active-sprint `editJiraIssue`, re-read the sprint field. An
active sprint was found but the field is still null → do not report success;
surface the unset field. Silent-skip covers only the no-active-sprint case,
never a failed write masquerading as one.

**Why:** The claim already fires active-sprint assignment (Stage 2 HARD RULE +
subroutine), yet a ticket worked mid-sprint still landed with a null sprint and
the user had to prompt — the write silently no-op'd while the claim reported
success. Escalation of the already-covered rule via a post-write verify.

**Where:** wk-jira Stage 2 Active-sprint assignment subroutine.
