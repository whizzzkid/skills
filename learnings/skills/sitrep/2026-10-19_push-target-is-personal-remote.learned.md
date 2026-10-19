---
skill: wk-sitrep
date: 2026-10-19
type: gap
severity: high
verified-against-source: n/a
---

The skill commits and pushes the live page and snapshots without checking where the remote lives.

**What happened:** The ops-log repo's remote was a private repository under a personal account. The skill (and project
instructions) push automatically, so chat excerpts, ticket details and cost figures reached a personal destination,
which employer data-handling policy forbids even when the repo is private.

**Root cause:** Stage 6 / Stage 8 assume the configured repo is an approved destination and never inspect the remote
owner before `git push`.

**Suggested fix:** Before the first push of a run, resolve `origin` and compare its owner against an approved-owner
list in config; on mismatch, commit locally, skip the push, and tell the user to move the repo to a company-managed
organization. Also keep confidential figures (spend, forecasts) out of rendered pages and snapshots.
