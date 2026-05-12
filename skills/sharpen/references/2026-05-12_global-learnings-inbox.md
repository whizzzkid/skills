---
name: global-learnings-inbox
description: Batch mode mirrors a global learnings inbox into the repo tree before distillation.
---

- **Rule:** Drain `~/.claude/skills/learnings/` into `$WK_SKILLS_HOME/learnings/skills/`
  before scanning the repo tree for unprocessed learnings.
- **Why:** Learnings captured outside the repo (e.g., wk-learn invoked from
  other projects) must be version-controlled and logged as `.learned.md`
  alongside repo-native ones, otherwise they vanish on the next sharpen pass.
- **Where:** Step "Source 1: Global learnings inbox" in batch mode; runs
  before Source 2 (repo learnings) so copied files distill via the same path.
