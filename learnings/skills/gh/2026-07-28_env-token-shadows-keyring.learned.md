---
skill: wk-gh
date: 2026-07-28
type: gap
severity: medium
verified-against-source: yes
---

An environment token can silently shadow a usable keyring credential.

**What happened:** GitHub CLI reads failed because an environment-provided token had
no repository or organization scopes, while `gh auth status` showed an inactive
keyring credential with the required scopes. Unsetting only the environment token
restored access.

**Root cause:** `wk-gh` validates organization scope but does not diagnose credential
precedence when `GITHUB_TOKEN` overrides the keyring account.

**Suggested fix:** After an unexpected `NOT_FOUND` or SAML/scope failure, inspect
`gh auth status`. When an unscoped environment token shadows a scoped keyring login,
retry with `env -u GITHUB_TOKEN gh ...` without printing either token.
