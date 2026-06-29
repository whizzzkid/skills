---
skill: wk-sharpen
date: 2026-06-29
type: gap
severity: low
---

Step 8 commit gate stalled across sessions because the SSH signing agent listed keys but could not sign.

**What happened:** A fully-staged fold passed install + prohibited-scan + all hooks, but `git commit` failed with "communication with agent failed" at signing. `ssh-add -l` succeeded and showed the signing key loaded, so prior sessions concluded the agent was ready and kept re-staging — yet the signer (1Password-backed `ssh-keygen -Y sign`) needs an interactive unlock/approval the headless shell can't trigger.

**Root cause:** Step 8 treats "signing blocked" as a transient failure to retry. It conflates agent *reachability* (listing keys) with signing *capability*. A loaded key in the agent is not proof the signer can produce a signature when an interactive unlock gates the private operation.

**Suggested fix:** In Step 8, on a signing failure, stop the retry loop and surface a single explicit ask: the signer needs an interactive unlock (e.g. 1Password) — do not re-run install/scan or re-stage. Note that `ssh-add -l` listing success does NOT prove the signer can sign; only a completed signed commit does.
