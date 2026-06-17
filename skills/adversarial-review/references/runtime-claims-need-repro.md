---
class: principle
---

# Runtime-behavior claims are `question` until reproduced

**Rule**

- Any finding asserting how a tool behaves under failure — exit codes, signal
  handling, `--write-out`/buffering flags, subshell/pipe semantics — is capped at
  `question` until reproduced in the playground. Never rate it `blocker` from
  first-principles reasoning.

**Why**

- The adversarial subagent reasons about tool internals from memory and gets them
  wrong (e.g. claimed `curl --write-out` discards the HTTP code on non-zero exit;
  in fact the write-out fires before the process exits, regardless of `-f`).
- An unverified `blocker` on a fabricated tool quirk forces a needless fix or
  blocks a correct change. Contract item 8 ("reproduce before claim") already
  requires this; it re-fired because the rule lived only at the verdict step, not
  at the subagent that emits the rating.

**Where**

- `skills/adversarial-review/SKILL.md` Step 3 subagent qualities
  (runtime-behavior-cautious) and Step 5 downgrade rule (escalated, named).
