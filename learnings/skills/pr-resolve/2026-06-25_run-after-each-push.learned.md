---
skill: wk-pr-resolve
date: 2025-06-25
type: gap
severity: medium
---

Run wk-pr-resolve after every new push to a PR — not just after CI on the first push — because bots re-review on each push and generate new unresolved threads.

**What happened:** After a second round of commits was pushed to a PR, the agent started the session retro without first running wk-pr-resolve. The user interrupted to invoke /wk-pr-resolve instead, revealing new bot findings from the latest push.

**Root cause:** wk-pr-resolve was treated as a one-time step rather than a per-push step. Bot reviewers post fresh findings on every new push; skipping pr-resolve after intermediate pushes leaves open threads unaddressed.

**Suggested fix:** After every successful push to a PR branch (not just the first), run wk-pr-resolve before running the session retro. Treat it as a mandatory loop: push → CI green → pr-resolve → (if no new commits) retro.
