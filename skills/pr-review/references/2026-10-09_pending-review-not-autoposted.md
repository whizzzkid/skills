---
class: principle
---

# The Phase 4 summary hands straight off to the pending-review POST

**Rule**

- After presenting the numbered findings summary, proceed to Phase 5 in the same turn; never ask "post as pending
  review?".
- The review is pending, so the user still decides at submit time. Pause only when the user said don't post, wait,
  or let me review first (Phase 5 HARD RULE).

**Why**

- A prose compression rewrote the end of Phase 4 as "present summary and wait for user approval", which contradicted
  the Phase 5 auto-create HARD RULE. The agent followed the earlier, softer line, stopped, and the user had to ask why
  nothing was posted. Root cause verified against `git log -S`: the conflicting phrase entered in the compression
  commit, not in an intentional rule change.

**Where**

`skills/pr-review/SKILL.md` → end of Phase 4.
