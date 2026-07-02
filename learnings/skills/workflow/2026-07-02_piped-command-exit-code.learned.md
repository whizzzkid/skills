---
skill: wk-workflow
date: 2026-07-02
type: correction
severity: high
---

A correctness claim was gated on the exit status of a piped command, masking a real lint failure.

**What happened:** The full CI-mirroring check was run as `check | tail`, and success was reported from the pipeline's exit status — which is `tail`'s, not the check's. A formatting failure went unnoticed until the command was re-run without a pipe.

**Root cause:** In a default shell, `$?` after `a | b` is `b`'s status; the target command's failure is swallowed.

**Suggested fix:** When verifying a command's outcome, never pipe it and read `$?`. Capture the target's own status — redirect output to a file and check `$?`, or read `${PIPESTATUS[0]}`. Add this as a verification-step guard.
