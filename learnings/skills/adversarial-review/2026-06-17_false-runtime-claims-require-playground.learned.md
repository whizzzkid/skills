---
skill: wk-adversarial-review
date: 2026-06-17
type: correction
severity: high
---

Adversarial subagent claimed `curl -sSf -w '%{http_code}'` discards the HTTP code on non-zero exit; this is incorrect — the write-out format always fires before the process exits.

**What happened:** The adversarial subagent flagged a runtime-behavior finding that `curl -f` combined with `-w '%{http_code}'` would not capture the HTTP status code on failure. A prior command subshell pattern (`http_code=$(curl ... ) || { ... }`) was presented as broken. The finding was a `blocker`.

**Root cause:** The subagent reasoned from first principles about bash subshell behavior rather than verifying the claim in a playground. `curl`'s `--write-out` format fires at the end of the transfer regardless of exit code; `-f` only changes the exit code, not the write-out. The subagent's model of the behavior was wrong.

**Suggested fix:** Step 5 (Playground Validation) already covers this in principle, but the skill should add an explicit trigger: any adversarial finding that describes a runtime tool's behavior under failure conditions (exit codes, signal handling, write-out flags, buffering) must be reproduced in the playground *before* it is rated `blocker`. An unreproduced runtime-behavior claim defaults to `question`, not `blocker`. Add this as a named heuristic in the "Downgrade unreproduced runtime claims" section of Step 5.
