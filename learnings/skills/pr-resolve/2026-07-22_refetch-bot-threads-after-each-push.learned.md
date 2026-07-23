---
skill: wk-pr-resolve
date: 2026-07-22
type: gap
severity: medium
---

A bot re-review regenerates its thread node IDs on every push, so cached GraphQL thread IDs go stale — always re-fetch threads against the current HEAD before resolving, and re-derive the (path, line, concern) map because the finding set itself changes across pushes.

**What happened:** After pushing a feedback-fix round, the agent tried `resolveReviewThread` with thread IDs captured before the push — all failed `NOT_FOUND`. A fresh query returned a different set of threads (some prior findings gone, new ones appeared) because the bot had re-run against the merged HEAD. Resolving by stale ID silently no-ops; matching by stale (path, line) mislabels new findings as already-addressed echoes.

**Root cause:** Bot review threads are not stable across pushes — the bot retracts and reposts. Thread node IDs and the finding set are both push-scoped, but the flow reused a pre-push snapshot.

**Suggested fix:** Make "re-fetch bot threads and re-classify by (path, line, concern) against the just-pushed HEAD" an explicit post-push step; never resolve using pre-push thread IDs. Note also that GraphQL `resolveReviewThread` is an internal state change that is NOT blocked by an author's pending self-review (unlike REST reply-creation, which 422s) — so thread resolution stays available even when replies are blocked.
