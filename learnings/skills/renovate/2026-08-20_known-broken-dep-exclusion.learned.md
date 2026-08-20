---
skill: wk-renovate
date: 2026-08-20
type: correction
severity: medium
verified-against-source: n/a
---

Batching open dependency-bump PRs should surface each package to the user before applying, so a known-broken upgrade can be excluded up front.

**What happened:** While combining several open dependency-update PRs into one branch, the agent began applying a major-version bump (a Redis client library) before the user interrupted: "don't upgrade redis yet, it doesn't work." The agent had already edited the manifest file for that bump when the correction landed.

**Root cause:** The skill's discovery step lists all open dependency-bump PRs and proceeds straight to applying them, with no checkpoint for the user to flag a package they already know is broken or blocked.

**Suggested fix:** After discovery, print the numbered summary table and pause for explicit confirmation (or an explicit "proceed" instruction) before applying any upgrade — especially for major-version bumps — so the user can exclude a known-broken package before edits start rather than after.
