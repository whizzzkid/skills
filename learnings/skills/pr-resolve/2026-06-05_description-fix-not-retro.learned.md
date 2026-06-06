---
skill: wk-pr-resolve
date: 2026-06-05
type: correction
severity: medium
---

Fixing a drifted description and marking PR ready does not substitute for wk-retro.

**What happened:** wk-pr-resolve was invoked to fix description drift and mark the PR ready. After `gh pr ready`, the session ended without invoking `wk-retro`, even though the skill's own Step 11 mandates it.

**Root cause:** The user's explicit directive ("fix the description, mark for review") was treated as the complete task scope, overriding the skill's mandatory retro step at the end.

**Suggested fix:** Step 11 (wk-retro) fires after every wk-pr-resolve session completion regardless of how narrow the user's instruction was. User directives define what to do; the skill's workflow defines how to finish.
