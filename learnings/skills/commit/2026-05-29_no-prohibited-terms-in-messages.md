---
skill: wk-commit
date: 2026-05-29
type: correction
severity: high
---

Never reference prohibited/internal terms in a commit message (or PR/issue text).

**What happened:** While scrubbing internal codenames out of files, the commit
messages describing the scrub enumerated the very tokens being removed — re-leaking
them into git history. Commit messages are part of history and survive file-level
cleanup, so a "describe what I scrubbed" message reintroduces the leak.

**Root cause:** wk-commit covered message format and signing but never forbade
naming internal/prohibited tokens in the message body.

**Suggested fix:** wk-commit must forbid prohibited terms in commit messages —
describe the change by category ("internal vendor/project codenames"), never by
naming the tokens. Enforce mechanically with a `commit-msg` hook that reads the
gitignored prohibited-terms file and blocks any match.
