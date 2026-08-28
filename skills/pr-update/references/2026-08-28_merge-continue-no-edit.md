---
class: principle
---

**Rule** — `git merge --continue` does not accept `--no-edit`; use
`GIT_EDITOR=true git merge --continue` to skip the editor in non-interactive flows.

**Why** — `--no-edit` is parsed only at merge start, not on the `--continue` resume path.
Passing it causes git to print option help and leave the merge uncommitted.

**Where** — `SKILL.md` → Stage 4 → Merge continuation command.
