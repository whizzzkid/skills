---
class: principle
date: 2026-08-11
skill: wk-env
---

# Interactive-shell config hides env vars from non-interactive sourcing

- **Rule:** After the standard `source $HOME/.profile` probe, try
  `zsh -ilc "printenv VAR"` as a fallback. Interactive-only config (blocks gated
  on `[[ -o interactive ]]` or loaded by plugin managers) is invisible to
  non-interactive subprocess sourcing.
- **Why:** Agent exhausted `source $HOME/.profile`, `source $HOME/.zshrc`, `env`, and grep
  across dotfiles without finding a var the user said was there. The var was set in
  interactive-only config. `zsh -ilc` spawns a login interactive shell that loads
  the full config chain.
- **Where:** Step 3 → new "Interactive-shell fallback" subsection; Step 3 report
  results → new "Resolved after interactive-shell probe" outcome.
