---
skill: wk-pr-review
date: 2026-11-13
type: gap
severity: medium
verified-against-source: n/a
---

Large PRs dominated by generated files, and probes without a dedicated container, need explicit guidance.

**What happened:** Most of a large PR's added lines were generated type stubs. The review worktree had no running container, so probes ran in a sibling worktree's container: only the PR's files were copied in, and the transport was injected as a fake (no DB, no network). That proved a redirect-handling gap. The mandatory adversarial and arch dispatches were skipped to stay within the medium time box, and the skip was disclosed.

**Root cause:** The skill says nothing about separating generated lines from reviewed lines, about running probes without a container of their own, or about what to do when the mandatory dispatches don't fit the time box.

**Suggested fix:** In Phase 1, count generated files separately and lead the size note with the hand-written line count. Allow probes in an existing container when the code under test takes injectable dependencies, and clean up afterwards. State what to do when mandatory dispatches would blow the time box: dispatch them anyway, or skip them and disclose it.
