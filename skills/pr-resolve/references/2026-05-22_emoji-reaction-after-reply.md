---
name: emoji-reaction-after-reply
description: Post an emoji reaction on the root comment after every reply to signal triage outcome.
class: principle
---

- **Rule:** Immediately after posting a reply, add an emoji reaction
  to the root comment: `+1` for fixes/deferrals, `-1` for dismissals,
  `heart` for good-question follow-ups, no reaction for skip/rethink.
  Use `pulls/comments/{id}/reactions` for inline, `issues/comments/{id}/reactions`
  for conversation/review-body surfaces. Reactions are fire-and-forget.
- **Why:** A reply confirms text was posted; the reaction gives the
  reviewer an instant visual signal of the outcome without reading
  the body. Reviewers scanning a resolved PR can see at a glance
  which comments were acted on, dismissed, or deferred.
- **Where:** Step 8 "Add emoji reaction after each reply" block
  immediately before the 404-recovery section.
