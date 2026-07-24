---
class: principle
skill: wk-env
date: 2026-07-24
severity: medium
---

- **Rule:** Distinguish "misconfigured" (fixable in-process) from "stale in this
  process" (not fixable in-process). A var reading `set` proves inheritance, not
  validity. On an auth failure against a `set` var: fingerprint the value (length +
  hash prefix, never the secret), source the candidate profile **once** in a
  subprocess, re-fingerprint. Unchanged → declare stale-in-process and ask the user to
  restart the session or run the command in their own shell. Never hunt a second shell
  file; never retry the command a third time.
- **Why:** A secrets manager injects the value into the *interactive* shell only, so a
  credential rotated after this process started leaves a stale copy that no amount of
  sourcing can refresh — every retry is guaranteed to fail identically. Without the
  distinction the agent burns turns cycling through candidate shell files and
  re-reading the same value, and the status table reports the var healthy the whole
  time. The fingerprint comparison is the empirical test, so it holds whether or not
  the profile itself re-mints the value.
- **Where:** Step 2 note that `set` ≠ valid, new Step 3.5 with the fingerprint
  procedure and the retry ceiling, Step 5 exit code 2 extended to stale-in-process.
- **Note:** The learning was filed against the workflow skill, but this skill owns
  every profile-sourcing instruction, so the mechanics landed here. The tool-specific
  auth-failure rule elsewhere (prompt for a fresh cloud login, do not retry) was left
  as-is — it is correctly scoped to its tool and does not over-generalize.
