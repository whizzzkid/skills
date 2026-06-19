---
skill: wk-retro
date: 2026-06-19
type: correction
severity: medium
---

Self-caught errors must route to wk-learn immediately during execution, not defer to retro.

**What happened:** During a sharpening run, a bug in a pre-commit hook was discovered and fixed. The learning about this discovery—the exact moment of diagnosis, the root cause identification, the fix pattern—was deferred and only captured at retro time (end of session), losing precision about the execution context and error mode.

**Root cause:** The wk-retro HARD RULE (Step 4: "invoke `wk-learn` per skill gap") addresses the reverse case: learnings named in the retro's "What could've been better" bullets. But when the agent self-catches an error during active execution (discovers a bug, finds a missing check, corrects own code), wk-learn should fire immediately in the same response—before, alongside, or after the fix commit. Deferring to retro collapses a multi-minute discovery sequence into a one-sentence summary, losing the moment of realization and the exact error context.

**Suggested fix:** Add a prominent protocol note to wk-retro, preceding or adjacent to Step 4's HARD RULE: "When the agent self-catches an error during skill execution (discovers a bug, identifies a missing check, corrects own code), invoke `wk-learn` immediately in that same response—do not defer the learning to retro time. Retro refines and promotes; it does not capture discoveries for the first time."
