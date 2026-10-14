---
class: principle
---

# Check the assignee before every terminal transition

**Rule**

- Before any terminal transition (Done/Resolved/Won't Fix) — lifecycle Stage 5, manual confirm-first operations, and
  each child in a batch close — fetch `assignee`.
- Unset → assign to the user (automatic, like the Stage 2 claim). Someone else → never reassign; report.
- Report the assignee state alongside the transition result.

**Why**

- The assignment step lived only in the Stage 2 claim. Resolving a parent and its auto-generated children outside
  the dev lifecycle commented and closed every ticket but left the children unassigned; the user had to ask.

**Where**

`skills/jira/SKILL.md` → Stages 3–5 (next to the Child-completion gate) and Manual ticket operations auto list.
