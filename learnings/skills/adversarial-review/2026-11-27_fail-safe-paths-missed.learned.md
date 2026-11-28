---
skill: wk-adversarial-review
date: 2026-11-27
type: gap
severity: medium
verified-against-source: n/a
---

The adversarial review cleared a fail-safe design that a later bot review broke in three places.

**What happened:** A runtime-flag client cleared review, then a review bot found three failure-path defects the pass
had missed:
- a memoized client that memoized only success, so a build failure re-ran and was re-reported on every read;
- a trace filter that dropped noisy background polls without checking error status, which hid the only signal of a
  failing poller;
- a mid-job check whose "unreadable reads as off" default silently dropped work the start check had already
  admitted.

**Root cause:** The review checked each policy at its entry point, but not how that policy behaves on the failure
path, for a repeated call, or at a later call site.

**Suggested fix:** For any fail-safe or default-on-error design, the review should ask three questions:
- Is failure cached the same way success is?
- Does a noise filter keep errored items?
- Does each later call site in the same unit of work inherit the right policy, or the wrong default?
