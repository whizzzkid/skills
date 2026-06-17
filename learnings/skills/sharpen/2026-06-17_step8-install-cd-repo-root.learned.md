---
skill: wk-sharpen
date: 2026-06-17
type: gap
severity: medium
---

Step 8 install must cd to the repo root explicitly; cwd can carry over from earlier steps.

**What happened:** The Step 8 install (`npx skills add . -g -y`) ran inside `learnings/` because a `cd` during the learning-rename step persisted (the Bash tool's cwd persists across calls). It printed "No valid skills found" since there is no SKILL.md there.

**Root cause:** Step 8 says "from the repo root" but relies on cwd already being there. Prior rename/scan commands may have changed cwd, so the relative `.` resolves wrong.

**Suggested fix:** Prefix the Step 8 install (and any `.`-relative command) with an explicit `cd "$WK_SKILLS_HOME"` (or absolute repo path) so it never inherits a stale cwd.
