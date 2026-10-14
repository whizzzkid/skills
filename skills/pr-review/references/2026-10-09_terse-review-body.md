---
class: principle
---

# One verdict line whenever inline comments carry the substance

**Rule**

- The one-line body applies whenever every finding has an inline anchor, not only for a clean LGTM.
- Never put review depth (shallow/deep, what was skipped), a list of what looked fine, or bot/duplicate-thread notes
  in the body. Tell the user about review depth in the terminal.
- Pre-POST gate: every sentence past the verdict must name an un-anchored concern, otherwise cut it.

**Why**

- The "LGTM is one line" rule was scoped to reviews with no concerns, so once inline comments existed the agent
  used the body for summary and context. The user cut it to the verdict line. The process-commentary ban already
  existed and was violated anyway, which is why the check became a mechanical gate.

**Where**

`skills/pr-review/SKILL.md` → Phase 5 body HARD RULE and pre-POST body gate.
