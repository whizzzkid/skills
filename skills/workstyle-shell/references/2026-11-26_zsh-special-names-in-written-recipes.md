---
class: principle
---

# Re-violation: zsh-special variable names in a recipe written into a skill

**Rule** — never name a shell variable `path`, `cdpath`, `fpath`, `manpath`, or `module_path` (tied to their uppercase
twins in zsh), and never assign `status` (read-only in zsh). The rule binds every recipe you *write down* — a fenced
block in a skill, reference, or doc that an agent may later execute — not only commands you run yourself.

**Why** — a recipe authored a month after this rule reached `**Important:**` assigned `path="worktrees/…"`; a subagent
ran it under zsh, the assignment replaced the search path, and the next command failed `command not found`. The rule
fired on commands the agent ran but not on recipe text it authored. Verified under zsh 5.9: `path=x; ls` → rc 127;
`status=0` → `read-only variable: status`, rc 1; `pipestatus=0` is assignable (not added).

**Where** — `SKILL.md` → Rules → zsh/bash portability sub-bullet (escalated `**Important:**` → `**Very important:**`,
widened to written recipes and `status`); `references/zsh-bash-portability.md` reserved-variable trap; capture rule
and `references/set-e-status-capture.md` renamed `status` → `rc`. Offending recipe corrected in the owning skill.
