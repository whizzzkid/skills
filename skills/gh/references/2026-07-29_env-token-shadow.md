---
class: principle
---

# Environment tokens can shadow stored credentials

**Rule** — after explicit stored/keyring authentication confirmation, run every `gh` command with `GH_TOKEN` and
`GITHUB_TOKEN` removed at the command boundary; do not inspect auth state or token values. Without confirmation,
compare normal and token-unset auth status before refreshing credentials.

**Why** — GitHub CLI gives environment tokens precedence over stored credentials. A narrower injected token can make
valid stored authentication look unauthorized or missing.

**Where** — `SKILL.md` → Step 0, before organization scoping.

**Verification** — `gh help environment` documents the precedence and stored-credential override. The command was run
with `GITHUB_TOKEN` removed and did not query live authentication state.

**Budget** — body `20647 + 1100 = 21747` bytes, leaving 2,829 bytes. Full-skill audit found no body cleanup; README
diagram cleanup connected three previously dead branches to the command path.
