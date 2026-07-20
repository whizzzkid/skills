---
class: principle
---

**Rule:** When a skill exists to run a write/mutating command (`gh pr merge`,
`git push`, `gh pr edit`, etc.), add a granular `Bash(<cmd>:*)` grant to that
skill's OWN `allowed-tools` frontmatter. Never self-add the grant to global
`$HOME/.claude/settings.json`.

**Why:** A bare `Bash` entry does not pre-approve write commands — the auto-mode
permission classifier still gates each write per-command, forcing a redundant
confirmation even though invoking the skill IS the authorization. The grant
belongs with the skill so it travels with the skill and does not widen global
scope; editing global `settings.json` to grant permission is itself
classifier-blocked and is the wrong scope.

**Where:** wk-skill, allowed-tools two-way HARD RULE.
