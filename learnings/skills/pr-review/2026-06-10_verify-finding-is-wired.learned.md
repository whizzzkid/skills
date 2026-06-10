---
skill: wk-pr-review
date: 2026-06-10
type: pattern
severity: medium
---

A bot "Blocker" on a code path is only a live blocker if that path is actually wired in production — check for the caller/env trigger before accepting severity.

**What happened:** Two bots ({bot}, {bot}) flagged a relocation PR as a Blocker: an asset-bootstrap allowlist still scoped to the old prefix would skip assets moved to the new prefix, "breaking re-exec and firewall init." Playground reproduction confirmed the allowlist mechanically skips the new paths. But tracing the trigger env var showed nothing sets it in production — the bootstrap is a no-op on every path that ships today; only a deferred, not-yet-wired path would hit it. The accurate verdict was "Confirmed but narrower than stated," not Blocker.

**Root cause:** Bots fire on static allowlist-vs-path mismatches without checking whether the consuming code path is reachable in the shipped configuration. Accepting the bot's severity verbatim would have over-escalated a latent forward-compat gap to a merge blocker.

**Suggested fix:** During bot-finding validation (Phase 4), in addition to reproducing the *mechanism*, grep for the **trigger** that activates the affected path (env var set in a compose/CI file, a live caller, a production config) before assigning severity. A mechanically-correct finding on dormant/future infrastructure is "Confirmed but narrower than stated." Also worth checking: when a PR *modifies a doc comment* that describes a mechanism, verify the comment still agrees with the code it points at — a freshly-edited-but-now-contradictory comment is a clean, defensible finding the bots often miss.
