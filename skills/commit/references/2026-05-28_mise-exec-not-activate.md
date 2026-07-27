---
class: principle
date: 2026-05-28
source:
  - ~/.claude/memory/feedback_mise_activate_before_push.md
severity: medium
---

- **Rule** — invoke push and any commit-time hook trigger via `mise exec -- git push` in mise-managed repos; never `eval "$(mise activate bash)"`.
- **Why** — the user explicitly corrected `eval "$(mise activate bash)"` → `mise exec --`; the `activate` form is for interactive shells and the single-command `exec` form is the supported way to inject mise PATH into a Bash tool session.
- **Where** — `wk-commit` Mise-managed repos section (replaced the stale `eval ... mise activate` recipe).

## Full procedure

Relocated verbatim from `SKILL.md` to hold the body under the size ceiling.

Project uses mise (`.mise.toml` or `.tool-versions`) → invoke push (and any
commit-time hook trigger) via `mise exec --` so git hooks (lefthook, husky, etc.)
find mise-managed binaries:

```bash
mise exec -- git push
```

Never use `eval "$(mise activate bash)"` — the supported single-command form is
`mise exec --`. Bash tool sessions don't inherit the user's interactive shell, so
without `mise exec --` hooks fail with "command not found" (exit 127) for tools
like `lychee`, `shellcheck`, `bats`, etc.
