---
class: principle
---

# Deleting the user's pending draft is a deniable destructive write

**Rule**

- When Phase 2 finds an own pending draft, the Phase 4 summary discloses that posting deletes and recreates it (with
  the count of the user's comments carried verbatim). Disclosure only — Phase 4 still never asks to post.
- Write the union payload to disk before the DELETE; run the DELETE as its own Bash call.
- DELETE denied → stop with the draft intact; report the review ID and payload path; ask the user once to authorize
  it or act themselves. Hook-rewrite denials get the one identical retry from `wk-env` Step 3.6 first.
- Never route around the denial (submitting the draft, a second review, live comments).
- POST denied after a landed DELETE → the payload file is the only copy of the user's comments; say so.

**Why**

- The append path treated deleting the user's own draft as routine, but an auto-mode permission classifier judged the
  DELETE an external destructive write and denied it, stalling the post until the user explicitly authorized it.
- The report suggested the summary disclosure would make the user's go-ahead cover the DELETE. Rejected as stated:
  Phase 4 never pauses for a go-ahead (installed rule wins), and an agent-written disclosure is not user consent. The
  disclosure is kept for visibility; the denial path is what actually prevents the stall from turning into data loss
  or a workaround.
- DELETE-then-POST has a window where the draft is gone and only the payload holds the user's comments, so the
  payload must exist before the DELETE and be named as the sole copy on a later failure.

**Where**

`skills/pr-review/SKILL.md` → Phase 4 summary paragraph and Phase 5 draft-DELETE HARD RULE;
`references/posting-pending-review.md` → "Append to existing pending review".
