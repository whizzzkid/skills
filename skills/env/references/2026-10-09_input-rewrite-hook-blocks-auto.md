---
class: principle
---

# A hook that rewrites Bash input blocks auto-mode writes

**Rule**

- Denial text `a hook changed this call's input after the model wrote it` → diagnose a `PreToolUse` `Bash` hook
  emitting `updatedInput`, not a missing var or a bad command.
- Retry the identical call once; second denial → stop and hand off to the user. Never a third attempt.
- Remediate the environment (observe-only hook, or env from the login-shell profile), never by reshaping the command.

**Why**

- The auto-mode classifier reviews the command as written; a rewriting hook makes the executed command differ, so the
  classifier returns no verdict. Read-only calls skip the classifier, so only writes fail — the symptom looks like a
  per-command permission problem.
- Verified against source: the global settings register a `Bash` hook that prepends a profile `source` to every
  command via `updatedInput`. Reproduced during a later drain: a `git push` was refused once with this text and passed
  on the single retry — the refusal is intermittent, so the one-retry rule is correct and a retry loop is not.

**Where**

`skills/env/SKILL.md` → Step 3.6.

**Not changed in this fold**

- The repo's hook manifest still ships the rewriting hook, and the registrar only adds entries, never removes them.
  Removing it changes env delivery on every machine and is a settings change for the user to decide; it was reported,
  not applied.
