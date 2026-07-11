---
skill: wk-adversarial-review
date: 2026-07-09
type: pattern
severity: medium
---

A test asserting on a shared observability sink (error tracker / metrics) can false-pass or false-fail when an unstubbed collaborator in the same code path routes into that same sink on its own error branch.

**What happened:** A spec asserted `ErrorTracking.notify_error` was (or was not) called by the method under test. A second collaborator (`Metrics.increment`) ran unstubbed in the same path and, per its own internal `rescue`, also calls `notify_error` when the metrics backend errors. So the "does not notify" assertion could false-fail on a backend hiccup, and the "does notify" assertion could false-pass via the collaborator rather than the intended path.

**Root cause:** Two independent code paths funnel into one observability sink. Asserting on the sink without isolating the unrelated caller couples the test to the collaborator's failure behavior instead of the behavior under test.

**Suggested fix:** When a finding or a new test asserts call-count on a shared sink (error tracker, logger, metrics, notifier), grep the same code path for other collaborators that write to that same sink — especially ones with an internal `rescue`/catch that reports errors. Require those collaborators stubbed so the assertion observes only the intended path; flag a `not_to receive`/`never` assertion on a shared sink as non-hermetic until they are.
