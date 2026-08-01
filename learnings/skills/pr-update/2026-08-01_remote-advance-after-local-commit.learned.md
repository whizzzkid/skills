---
skill: wk-pr-update
date: 2026-08-01
type: gap
severity: medium
verified-against-source: yes
---

Handle a remote base merge that lands after a local commit without rewriting
either history.

**What happened:** A normal push was rejected because the remote PR branch had
gained a hosting-provider-created base merge while a reviewed commit existed
only locally.

**Root cause:** The skill covers updating from the base and retrying after lease
failures, but it does not spell out the concurrent case where the remote PR
branch already contains the base merge.

**Suggested fix:** On a non-fast-forward push, fetch and inspect the remote PR
tip; when it contains only a legitimate base merge, merge the remote tracking
branch locally, revalidate, and retry a normal push without rebasing or
forcing.
