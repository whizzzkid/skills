---
skill: wk-env
date: 2026-08-11
type: correction
severity: medium
verified-against-source: yes
---

Environment variables set only in interactive shell config are invisible to
non-interactive sourcing — use `zsh -ilc` to retrieve them.

**What happened:** Agent could not find `CLOUDSMITH_API_KEY` via `source
$HOME/.profile`, `source $HOME/.zshrc`, `env`, or `grep` across dotfiles. User said
"source the profile you'll find it." The variable was set in interactive-only
shell config (likely a conditional block gated on `[[ -o interactive ]]` or
loaded by a plugin manager that only runs interactively).

**Root cause:** Non-interactive `source $HOME/.zshrc` skips blocks guarded by
interactive-mode checks, and `env` only shows the current process's
environment. `zsh -ilc 'echo $VAR'` spawns a login interactive shell that
loads the full config chain including plugin managers and conditional blocks.

**Suggested fix:** When `wk-env` fails to find a declared env var via the
standard source-and-check path, add a `zsh -ilc 'echo $VAR_NAME'` fallback
before reporting missing. If that succeeds, export it into the current
session and note the interactive-only source for the user.
