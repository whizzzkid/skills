---
class: principle
---

# A body sync must re-run the footer gate on the new body, not the old one

**Rule**

- A PR-body sync is not complete until the outbound-footer gate has run on the
  body string being emitted — never on the one it replaced.
- Match the exact canonical footer string before deciding not to re-emit.
- Replace a commit-message-trailer block found in an inherited body; never
  preserve it as if it were the footer.

**Why**

- The commit-message trailer and the canonical outbound footer open with the same
  words, so a carried-over trailer satisfies an at-a-glance "the body already has
  a footer" check and the gate is skipped.
- A from-scratch compose naturally triggers the gate; an edit of an inherited
  body does not. The old rule's duplicate-suppression clause was the escape hatch
  that let a look-alike block through, so the sync step's definition of done
  covered content drift but never named the footer gate.

**Escalation** — the existing "route through `wk-gh`" bullet was re-violated;
bumped one rung, baseline prose → `**Important:**`, and reframed so the gate is
stated against the new body rather than as a duplicate check.

**Where**

- `SKILL.md` → PR Sync → *Rules for the refresh*.
