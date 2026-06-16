---
skill: wk-adversarial-review
date: 2026-06-16
type: pattern
severity: medium
---

Gate reorder changes test assertions, not just behavior — analyze test context before clearing.

**What happened:** A refactor moved cheap local guards (threshold check, findings-count check) to run *before* a method that includes a network call. The adversarial review caught that one existing test asserting `not_to receive(:fetch_diff)` was missing a `not_to receive(:fetch_pr_head_sha)` assertion — but more importantly, the subagent correctly explained *why* the old test lacked that assertion: under the old gate order, with the test's outer `around` block setting all required env vars, `fetch_pr_head_sha` *would* genuinely be called. The test was structurally honest before the reorder; after the reorder it needed updating, and adding the new assertion also revealed a latent unstubbed-network-call hazard in the old test.

**Root cause:** Gate reorders affect not just behavior (which may be unchanged, all paths still return false) but also *which calls get made* on the failure paths, meaning existing negative-assertion tests may be simultaneously correct (pre-reorder) and incomplete (post-reorder). A reviewer focused only on return-value behavior misses this.

**Suggested fix:** When reviewing a gate-reorder diff, explicitly enumerate which test cases previously had a call on the reordered path and now should not. For each, verify the test asserting `not_to receive` covers all calls that are now unreachable, not just the deepest one (the diff usually only touches the deepest assertion; earlier calls in the chain also become unreachable and should be asserted).
