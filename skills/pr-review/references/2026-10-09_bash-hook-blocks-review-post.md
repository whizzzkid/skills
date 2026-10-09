---
class: principle
---

# The pending-review POST runs as its own single Bash call

**Rule**

- Build the footer, write the payload (Write tool), run the footer gate, and `open` the URL as separate calls; the
  `gh api .../reviews --method POST --input <file>` call stands alone.
- Denial `a hook changed this call's input` → retry the identical POST once; second denial → stop, report the payload
  path, and ask the user to re-authorize or post it. Diagnosis lives in `wk-env` Step 3.6.

**Why**

- A compound command (footer build, `jq -n` payload, footer gate, POST, `open`) was refused twice under auto mode and
  the review went unposted. A payload written with the Write tool plus a lone POST went through.
- Verified: a global `PreToolUse` `Bash` hook rewrites every command via `updatedInput`. Not verified: why the lone
  call passed when the compound one did not — both are rewritten, and the refusal is intermittent. Command length is
  NOT claimed as the trigger. The rule rests on what is certain: an isolated write keeps reads and gates from failing
  with it, and is cheap to retry once or hand off.

**Where**

`skills/pr-review/SKILL.md` → Phase 5 (HARD RULE); `references/posting-pending-review.md`.
