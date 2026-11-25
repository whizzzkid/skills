---
skill: wk-git
date: 2026-11-25
type: surprise
severity: medium
verified-against-source: no
---

When the SSH agent refuses to sign, a global `url.git@github.com:.insteadOf https://github.com/` rewrite defeats a plain HTTPS fallback push.

**What happened:** `git push` failed with `sign_and_send_pubkey: signing failed ... communication with agent failed`. Retrying with `https://github.com/...` and the `gh` credential helper was silently rewritten back to SSH by the insteadOf rule. A userinfo URL (`https://x-access-token@github.com/...`) dodged the rewrite, but the gh helper then supplied no password (`could not read Password ... Device not configured`).

**Root cause:** (unverified — inferred from symptom) The insteadOf prefix matches the bare HTTPS host. `gh auth git-credential` appears not to answer when the request carries a username it does not own.

**Suggested fix:** On an SSH agent signing failure, stop after one retry and ask the user to unlock or restart their agent (for example a password-manager SSH agent). Don't chain HTTPS workarounds. Any HTTPS fallback must avoid both the insteadOf prefix and a mismatched username.
