---
skill: wk:sharpen
date: 2026-04-27
type: gap
severity: medium
---

The project mandates `npx skills add . -g -y -a=claude` after every skill edit, but enforces it via a CLAUDE.md instruction rather than a tooling hook — leaving correctness dependent on the agent remembering each time and on running from the right working directory.

**What happened:** Across a sharpen session that touched 4 skill files in 3 batches, the agent had to manually run `npx skills add . -g -y -a=claude` after each batch. One invocation failed silently with "No skills found" because the working directory had drifted into a subdirectory (`learnings/skills/...`) after a prior `mv`/`cd`-style command — the install command needs to run from the repo root where the top-level `skills/` directory lives. The user had to ask "were the new skills auto-installed?" to verify, and the only way to confirm was reading back the `Done!` line from each invocation.

**Root cause:** Two compounding gaps. (1) There is no `PostToolUse` hook on Edit/Write to `skills/**/SKILL.md` that fires the install command automatically — every install is a hand-run the agent must remember. (2) The install command is path-sensitive (must run from repo root) but no precondition check verifies that, so a working-directory drift produces a silent no-op rather than a loud error.

**Suggested fix:** Two-part. (a) Add a Claude Code `PostToolUse` hook (in `~/.claude/settings.json` or the repo's `.claude/settings.json`) that matches edits/writes under `skills/**/SKILL.md` and runs `(cd "$CLAUDE_PROJECT_DIR" && npx skills add . -g -y -a=claude)` — eliminates the remember-to-run problem and pins the working directory. (b) Until the hook is in place, in `wk:sharpen`'s post-edit step, before running the install, confirm pwd is the repo root with a top-level `skills/` directory (`test -d ./skills || cd "$(git rev-parse --show-toplevel)"`) and check the install output for "Done!" before declaring the run complete — treat "No skills found" as a hard failure that requires retry, not a silent skip.
