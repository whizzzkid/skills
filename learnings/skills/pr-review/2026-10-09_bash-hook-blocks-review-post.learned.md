---
skill: wk-pr-review
date: 2026-10-09
type: correction
severity: high
verified-against-source: no
---

A global PreToolUse Bash hook that rewrites every command blocked the pending-review POST in auto mode.

**What happened:** The user-level settings define a PreToolUse hook on `Bash` that returns
`updatedInput` with `source $HOME/.claude/profile.sh >/dev/null 2>&1; ` prepended to every command.
In auto mode, a long compound command (build footer, build payload with `jq -n`, footer gate, `gh api
.../reviews --method POST`, `open`) was refused twice with "a hook changed this call's input after the
model wrote it". The agent stopped and reported the review as unposted. The user had to step in.
Writing the payload with the Write tool and then running a single short
`gh api repos/{owner}/{repo}/pulls/{n}/reviews --method POST --input <file>` went through.

**Root cause:** The hook was read and confirmed: it rewrites every Bash call with no condition.
(unverified, inferred from symptom) Why the classifier refused the long call but accepted the short
one, even though both were rewritten, was not confirmed. The short call working does not prove that
command length is the trigger.

**Suggested fix:**
- Environment (preferred): remove the hook and rely on login-shell env plus `wk-env` sourcing. Or
  make it a no-op when the env it provides is already present. Or narrow its matcher so it does not
  rewrite `gh` write calls.
- Skill: Phase 5 already says to write the payload with the Write tool. Enforce that, and make the
  POST its own single, short Bash call (no chained footer gate or `open`). Run the footer gate and
  `open` as separate calls.
- When a hook-rewrite refusal happens, retry once in the short form above before telling the user
  it is blocked.
