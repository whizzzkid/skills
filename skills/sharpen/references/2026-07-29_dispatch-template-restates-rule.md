---
class: principle
---

# Dispatch templates are semantic rule copies

**Rule** — ordering, selection, or scope changes require scanning the skill's own references for
dispatch/spawn prompt templates and quoted self-instructions, then synchronizing every paraphrase.

**Why** — a prompt template emits prose rather than a link. Link and orphan checks can pass while
the template silently contradicts its owning rule.

**Where** — `SKILL.md` → Step 7 drift check. The loop-mode prompt was audited and already carries
the current severity-first, oldest-mtime tie-break.

**Budget** — body `24452 + 222 - 408 = 24266` bytes. Full skill and prompt-template audit found no
additional cleanup, so measured audit allowance was 0 bytes.
