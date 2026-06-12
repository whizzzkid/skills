---
class: one-off
date: 2026-06-12
---

- **Scenario:** A CI script forwards the commit author/actor identity to an
  external tool, and a spec phrases it as "pass the PR author identity".
- **Symptom:** Plan defaults to constructing an RFC-2822 mailbox string from a
  GitHub API PR-author response — an extra API call that returns the PR-opener,
  not the commit author, and is not mailmap-normalized.
- **Fix:** Read identity from commit history instead:

  ```bash
  git log -1 --pretty="%aN <%aE>"
  ```

  It is the canonical, mailmap-normalized author of the patch and needs no API
  call. Fall back to the API only if commit history is unavailable or the
  required field is genuinely the PR-opener rather than the commit author.
- **Why not promoted:** Fires only under the narrow config of CI actor-identity
  forwarding — not on most workflow invocations.
