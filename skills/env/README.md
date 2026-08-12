# wk-env

Diagnoses environment variable availability before skill execution and provides
actionable remediation.

**Version:** `2026.08.12-161750`

## Purpose

All user settings live in `$HOME/.profile`. When Claude Code is not launched
from a shell that sources that file, skills that depend on env vars like
`$WK_SKILLS_HOME`, `$GITHUB_ORG`, or `$EMPLOYER` see them as unset — causing
silent failures or fallbacks. [`wk-env`](../env/README.md) detects this mismatch, shows what is
resolvable by restarting from the right shell, and tells the user exactly what
to add to `$HOME/.profile` for vars that are genuinely missing.

## Trigger

- **Auto** — `PreToolUse` hook fires before any `Skill` tool call and checks
  the `env-vars:` frontmatter declared by the target skill.
- **Manual** — `/wk-env`, `/wk-env <skill-name>`, `/wk-env --check VAR1 VAR2`

## Key rules

- Source `$HOME/.profile` in a read-only subprocess to test resolution.
- Exit 0 (all set), 1 (resolved after sourcing → restart), 2 (still missing →
  add to `$HOME/.profile`, or stale-in-process → restart the session).
- Never write to global config, shell RCs, or `.env` files to "fix" a missing
  var.
- **Never print a secret-shaped value** (`TOKEN|KEY|SECRET|PASS|CRED|PAT`) — report
  `<len N sha XXXXXXXX>`; a printed prefix is a disclosure. Literal values are shown
  only for non-secret vars, where the value is the actionable diagnostic.
- **Resolve a skill's dir by listing, never by transforming its name.** Most dirs drop the
  leading `wk-`, some keep it — a blind strip builds a path that never exists, so the hook
  exits silently and checks none of the declared vars. Try verbatim, then stripped, and
  take the first that exists. An unresolvable name is normal (plugin and third-party
  skills ship no dir here) and must stay silent, never conflated with "declares nothing".
- **`set` means inherited, not valid.** A rotated secret still reads `set`, so an
  auth failure on a `set` var routes to the stale-value check: fingerprint the value
  (length + hash prefix), source once, re-fingerprint. Unchanged → stale-in-process,
  ask for a session restart. Never hunt a second shell file or retry a third time —
  a static profile cannot import a value minted after this process started.

## Frontmatter integration

Skills declare their env dependencies via:

```yaml
env-vars:
  - WK_SKILLS_HOME
  - GITHUB_ORG
```

The hook script ships inside this skill at `skills/env/hooks/check-skill-env-vars.sh`
(installed to `$HOME/.agents/skills/wk-env/hooks/`). It reads this field and warns
about missing/unresolved env vars before the skill body executes.

Its test suite lives at `skills/env/tests/env-hook.bats` — run `bats skills/env/tests/env-hook.bats`
before committing any change to the hook. It covers both dir-naming conventions, both
silent exit-0 branches, and each var state. Every assertion carries an explicit
`|| return 1`: this bats does not apply `errexit` to test bodies, so a bare assertion
that is not the final command in a test is inert and the test passes regardless.

Hooks cannot auto-register from a plain skill — Claude Code loads hooks only from
`settings.json` or a plugin manifest. So the script lives with the skill, but a
one-line `PreToolUse` (matcher `Skill`) registration pointing at the installed
path must be added to `~/.claude/settings.json`. The `Skill` matcher is global by
nature: it fires before *every* skill invocation, then no-ops for skills that
declare no `env-vars:`.

## Integration points

A skill declares only env vars it actually references in its body and that the
user manages through `$HOME/.profile` (two-way match, same discipline as
`allowed-tools`). When such a var is missing, "add it to `$HOME/.profile`" is the
correct nudge — `.profile` is the user's single source of truth for settings:

- [`wk-gh`](../gh/README.md) — `GITHUB_ORG`
- [`wk-sharpen`](../sharpen/README.md) — `WK_SKILLS_HOME`, `GITHUB_ORG`, `EMPLOYER`
- [`wk-learn`](../learn/README.md) — `WK_SKILLS_HOME`, `GITHUB_ORG`, `EMPLOYER`

Session-injected vars (e.g. `GIT_CONFIG_PARAMETERS`, set by the 1Password agent,
not exported in `$HOME/.profile`) are **not** declared here — "add to `.profile`"
is the wrong remediation for them. [`wk-commit`](../commit/README.md)'s own signing-failure protocol
owns that diagnostic.
- Hook: `skills/env/hooks/check-skill-env-vars.sh` (installed to
  `$HOME/.agents/skills/wk-env/hooks/`)
  Registered in `~/.claude/settings.json` → `hooks.PreToolUse[Skill]`
