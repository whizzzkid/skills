---
skill: wk-workflow
date: 2026-06-05
type: correction
severity: high
---

wk-retro is mandatory after marking a PR ready — skipping it is a workflow violation.

**What happened:** After `gh pr ready` succeeded and was reported to the user, the session ended without invoking `wk-retro`. Phase 8 of wk-workflow and Step 6 of wk-pr both mandate it unconditionally.

**Root cause:** Marking the PR ready felt like a natural session terminus, causing the retro step to be dropped. "Work is done" != "workflow is done" — the retro is part of the workflow contract, not an optional epilogue.

**Suggested fix:** After every `gh pr ready` call, the very next action must be `Skill(wk-retro)` — no user prompt, no asking, no exceptions. Treat it identically to how wk-commit is treated after code changes: non-negotiable, automatic.
