---
skill: wk-env
date: 2026-10-09
type: correction
severity: high
verified-against-source: yes
---

A PreToolUse Bash hook that rewrites `updatedInput` (to source a profile) blocks outward-facing writes in auto mode.

**What happened:** In auto mode, the agent tried to create a pending PR review with
`gh api repos/{owner}/{repo}/pulls/{n}/reviews --method POST --input <file>`. The call was denied three times
with "classifier gave no verdict: a hook changed this call's input after the model wrote it". Read-only `gh`
calls in the same session went through. The POST only ran after the user explicitly re-authorized it in a new
turn.

**Root cause:** The global settings register a PreToolUse hook with matcher `Bash`. It emits
`hookSpecificOutput.updatedInput` and prepends `source $HOME/.claude/profile.sh >/dev/null 2>&1; ` to every
command (confirmed by reading the settings file). The auto-mode classifier reviews the command as the model wrote
it. Because the hook mutates the input, the reviewed command no longer matches the one that would run, and the
classifier refuses to give a verdict. Read-only commands skip the classifier, so the bug only shows up on writes.

**Suggested fix:**
- Remove the input-rewriting Bash hook. Load profile env without mutating the command: export it from the
  login-shell profile the Bash tool already initializes from, or set `BASH_ENV` / settings `env`, or let wk-env
  source it on demand only when it finds a missing variable.
- If a hook must stay, make it observe-only (exit 0, no `updatedInput`). Never rewrite `tool_input.command`.
- wk-env diagnostics: when the error is "a hook changed this call's input", name the rewriting hook and point to
  this fix instead of retrying.
- wk-pr-review / wk-gh: when this error blocks a pending-review POST, write the payload file and ask the user to
  re-authorize or post it themselves. Do not retry more than twice.
