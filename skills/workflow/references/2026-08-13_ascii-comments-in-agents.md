---
class: already-covered
source: learnings/skills/workflow/2026-08-13_ascii-comments-in-agents.md
date: 2026-08-13
skill: wk-workflow
covered-by: wk-workstyle-ruby
---

## Coverage

Already covered by `wk-workstyle-ruby/SKILL.md`:

- "ASCII-only in source comments. Use `-`, `->`, `--`, `...` — not em dash (`—`), en dash (`–`), smart quotes, or Unicode ellipsis."
- "Run `bundle exec rubocop --no-color <changed-files>` on every changed `.rb` file before staging"

The root cause (agents unable to lint in worktree isolation) is now addressed by
`wk-workflow` HARD RULE "worktree-isolated agents cannot run Bash" — the coordinator
must run linters after agents complete edits.

No escalation: the existing rule was not bypassed; agents lacked the tool access
to execute it, which is a harness constraint now documented.
