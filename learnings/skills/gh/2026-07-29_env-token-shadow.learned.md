---
skill: wk-gh
date: 2026-07-29
type: surprise
severity: medium
verified-against-source: yes
---

Environment-provided tokens can shadow a sufficient stored GitHub CLI login.

**What happened:** GitHub write operations reported missing scope or `404` while a stored CLI login already had repository write scope; rerunning with the environment token unset succeeded.

**Root cause:** The GitHub CLI preferred `GITHUB_TOKEN` over its keyring credential, so the narrower environment token controlled both GraphQL and REST requests.

**Suggested fix:** When a GitHub write unexpectedly fails authorization, compare normal and `env -u GITHUB_TOKEN gh auth status` output before refreshing credentials, then scope the environment override only to the affected command.

## Additional evidence

- When the user expects the keyring-authenticated client, reload the login profile and run `gh` from that shell without forwarding a session-injected `GITHUB_TOKEN`.
- When the user explicitly confirms keyring authentication, do not inspect tokens or auth status; invoke each `gh` command with `GITHUB_TOKEN` removed from its environment.
