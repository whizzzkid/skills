---
class: one-off
date: 2026-08-10
skill: wk-gh
---

# Sandbox environment produces auth false negatives

- **Scenario:** `gh auth status` reports invalid credentials in a sandboxed
  environment that cannot reach the GitHub API or the OS keychain.
- **Symptom:** Both stored-token and API-connectivity probes fail with misleading
  "invalid token" errors, even though the credential is valid outside the sandbox.
- **Fix:** When both `gh auth status` and `gh api user` fail inside a restricted
  environment, rerun in the user's login shell (`zsh -ilc 'gh auth status'`). If
  that succeeds, the credential is valid and the sandbox is the barrier — do not
  ask the user to re-authenticate.
- **Why not promoted:** Step 0 already covers unexpected auth failures with the
  normal-vs-token-unset comparison. The sandbox case is a rare-configuration
  failure mode (network isolation, not bad credentials). Body at ceiling (9 B
  headroom).
