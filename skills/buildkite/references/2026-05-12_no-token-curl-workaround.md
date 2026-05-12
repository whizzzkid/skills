---
name: no-token-curl-workaround
description: Never extract a bk token and curl the Buildkite REST API as an auth workaround.
---

- **Rule:** When `bk` returns 401/403 or a missing-scope error, stop and
  request `bk auth login` — do not pull the token from local config and
  curl the REST API.
- **Why:** Scope-shaped failures look identical to credential-shaped ones
  in HTTP status; curl workarounds bypass scope checks, leak creds into
  shell history, and produce multi-turn dead ends.
- **Where:** "Auth Error Handling" section in `buildkite/SKILL.md`.
