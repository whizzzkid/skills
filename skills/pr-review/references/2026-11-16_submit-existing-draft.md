---
class: principle
---

# Reuse an unchanged own pending draft instead of delete+recreate

**Rule**

- Own pending draft whose `commit_id` equals `PR_HEAD` and whose re-verified comment set (path + body) matches the
  intended payload exactly → skip the DELETE and recreate.
- Approve gate passes → submit the existing draft via the `events` endpoint; else leave it pending (update a drifted
  body only).
- Any added, dropped, or edited comment, or a moved head → the full delete+recreate path.

**Why**

- The append path mandated delete+recreate for every own draft. When nothing changed, that only adds a destructive
  DELETE a permission layer may deny, plus a window where the payload file is the only copy of the user's comments.

**Where**

`skills/pr-review/SKILL.md` → Phase 2 "Own pending draft" bullet and Phase 4 summary disclosure;
`references/posting-pending-review.md` → "Append to existing pending review".
