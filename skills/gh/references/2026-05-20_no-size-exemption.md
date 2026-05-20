---
name: no-size-exemption
description: Every gh write triggers this skill, regardless of perceived size or surface.
class: principle
---

- **Rule:** Every `gh` write — including `gh pr comment`,
  `gh issue comment`, reply posts, and one-line API POSTs — fires
  this skill. No size, surface, or "just a comment" exemption.
- **Why:** Models self-filter "it's small" / "it's a comment, not a
  PR edit" against the skill's trigger and silently skip the footer
  and scoping checks. The footer is then missing from the live
  message and only surfaces when the user notices.
- **Where:** Skill opening paragraph, "HARD RULE — no size or
  surface exemption" callout immediately under the activation line.
