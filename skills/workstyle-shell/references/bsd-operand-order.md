---
class: principle
---

**Rule:** On macOS/BSD, options are not reordered after the first operand — put
flags before operands or terminate options with `--`; and run only commands with a
known, intended effect (no speculative "guard" lines).

**Why:** `mv src -v` treats `-v` as the destination and silently renames `src` to
`./-v` (GNU would read it as a flag). A stray token in operand position mutates the
filesystem, not just prints diagnostics.

**Where:** Shell rules list, alongside the BSD/GNU capability-probe rule.
