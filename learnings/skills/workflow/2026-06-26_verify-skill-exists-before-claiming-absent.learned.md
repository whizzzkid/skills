---
skill: wk-workflow
date: 2026-06-26
type: correction
severity: high
---

Verify a skill exists via filesystem before claiming it does not exist.

**What happened:** Agent claimed a skill did not exist because it was not in the session's available-skills list, without checking the filesystem. The skill existed at `$WK_SKILLS_HOME/skills/<skill-name>/`.

**Root cause:** The available-skills list in the session context is not exhaustive — skills can exist on disk but not appear in the list depending on how the session loaded. Agent treated the absence from the list as proof of non-existence.

**Suggested fix:** Before telling the user a skill does not exist, run `ls $WK_SKILLS_HOME/skills/ | grep <name>` or check the known-skills registry. Only claim a skill is absent after the filesystem check returns nothing.
