---
skill: wk-workflow
date: 2026-07-17
type: correction
severity: medium
---

Never emit throwaway "noop guard" shell commands mid-workflow — they can parse destructively.

**What happened:** During a skill's commit step, the agent appended a pointless
`mv skills/foo -v` line intended as a harmless guard. BSD `mv` (macOS) parses a
trailing `-v` as the **destination operand**, not a verbose flag, so it silently
renamed the directory to `./-v`. The skill dir vanished from its expected path
and downstream steps failed until it was restored with `mv ./-v skills/foo`.

**Root cause:** Emitting a command "just in case" with no verified effect. The
token meant as a flag landed in operand position, and `mv` acted on it literally.

**Suggested fix:** Only run shell commands with a known, intended effect — no
speculative guard lines. When a flag must follow operands, terminate options with
`--` or place flags before operands. On macOS assume BSD tool semantics (flags
are not reordered after the first operand), not GNU.
