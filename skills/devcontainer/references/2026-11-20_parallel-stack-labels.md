---
class: principle
source: learnings/skills/devcontainer/2026-11-20_parallel-stack-labels.learned.md
date: 2026-11-20
skill: wk-devcontainer
---

**Rule** — A second stack started by raw `docker compose` (port override for a sibling worktree's clash) is invisible
to `devcontainer exec` until its override stamps both `devcontainer.local_folder` and `devcontainer.config_file`
labels. Grep hooks for `devcontainer exec` fallbacks before choosing the throwaway-container path. Host access still
needed → remap with `ports: !override [...]` instead of `!reset []`.

**Why** — A compose override remapped the app port and the stack ran, but a pre-commit hook falling back to
`devcontainer exec --workspace-folder .` failed with "Dev container not found", so commits could not pass hooks.
Adding both labels and recreating the app service made the lookup resolve (verified).

**Escalation** — Re-violation of the label rule installed 2026-10-30 (before the report): `**Important**` →
`**Very important**`, with the hook-fallback case named. The `!override` remap is a genuine gap (installed text only
reset ports).

**Where** — `SKILL.md` → "Host port already bound by a sibling worktree"; README Noteworthy.
