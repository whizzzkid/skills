---
skill: wk-sharpen
date: 2026-06-15
type: correction
severity: high
---

Sharpening must always de-bloat — enforce a hard SKILL.md size ceiling, never let prose accrete.

**What happened:** Over many sharpening passes, skills accumulated so much fluff
(repeated rationale, verbose prose, redundant examples) that several SKILL.md
files exceeded 1000–1800 lines. The {user} had to spend an entire weekend with
another agent validating the bloated skills and fixing them. Sharpening had been
treated as additive — appending the latest learning's rule — without ever
removing what compression made redundant.

**Root cause:** Each sharpening pass optimized for capturing the new rule, not for
total document health. Without a size ceiling and a mandatory de-bloat step, every
pass grew the file; bloat is the cumulative default of additive edits.

**Suggested fix:** Make the de-bloat/concision pass non-optional on every
sharpening run (not just when a learning prompts it), and enforce a hard size
ceiling per SKILL.md (target 24k bytes). When a skill exceeds the ceiling, the
pass must refactor, split into references/sub-skills, or scope down the offending
skill before finishing — coverage-preserving, never by dropping a HARD RULE,
error code, or failure-mode. A pre-commit hook in the repo enforces the same 24k
ceiling so bloat cannot be committed; sharpen should keep files well under it
rather than relying on the hook as the only guard.
