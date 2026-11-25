---
class: principle
skill: wk-commit
date: 2026-11-25
---

# SSH-agent push refusal: retry once, then ask; never chain HTTPS fallbacks

- **Rule:** When `git push` fails because the SSH agent refuses to sign (`sign_and_send_pubkey: signing failed`,
  `agent refused operation`, `communication with agent failed`), retry once, then stop and ask the user to unlock or
  restart their agent. Never chain transport workarounds.
- **Why:** An HTTPS retry was silently rewritten back to SSH by a global `url.<ssh>.insteadOf https://<host>/` rule.
  A userinfo URL dodged the rewrite, but the `gh` credential helper then supplied no password
  (`could not read Password ... Device not configured`). Each workaround produced a different error string, which
  invites a fresh diagnosis of a fault already diagnosed as the agent.
- **Verified:** `git -c url.git@github.com:.insteadOf=https://github.com/ ls-remote --get-url https://github.com/o/r`
  prints the SSH form, while the same with `https://x-access-token@github.com/o/r` is left untouched (prefix match on
  the bare host). `gh auth git-credential get` exits 1 for a request carrying a username it does not own, and returns a
  password when no username is sent.
- **Where:** `SKILL.md` → Pushing → Hook and verify rules, before the push-rejected rule. Related coupling of commit
  signing and push auth on one agent: `skills/sharpen/references/2026-07-28_signer-outage-spans-commit-and-push.md`.
