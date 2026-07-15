---
skill: wk-pr
date: 2026-07-15
type: gap
severity: medium
---

Scope measurement against a local base ref reports phantom additions when the local default branch is stale.

**What happened:** `git diff <base>...HEAD --stat` showed ~990 phantom additions (files already merged) because the local default-branch ref lagged the remote; the true remote delta was ~490. The base-detection loop also returned a failure sentinel while a direct `origin/<base>` merge-base gave the correct distance.

**Root cause:** the skill computes distance/scope using candidate refs that may resolve to a stale local branch instead of `origin/<branch>`; a local default branch behind the remote yields an older merge-base and inflates the diff.

**Suggested fix:** always fetch and diff/measure scope against `origin/<base>` (never the local ref); when the detection loop returns its failure sentinel but a direct `origin/<base>` merge-base succeeds, trust the remote result rather than defaulting.
