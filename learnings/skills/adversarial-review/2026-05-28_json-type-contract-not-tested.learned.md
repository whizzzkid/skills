---
skill: wk-adversarial-review
date: 2026-05-28
type: gap
severity: medium
---

JSON.parse type-coercion contracts documented in comments but not pinned by tests went undetected.

**What happened:** A code comment explicitly documented that only Ruby `false` (not the string `"false"`) triggers a gate, because `JSON.parse` maps JSON `false` → Ruby `false`. A bot reviewer flagged that no test pinned this contract. The adversarial review's comment-accuracy pass did not identify the gap between the documented type invariant and the test suite.

**Root cause:** The comment-accuracy sweep (Step 2.4) checks behavioral claims for staleness against the *implementation*, but does not cross-check whether the claim is covered by a *test*. A comment accurately describing behavior that has no pinning test is an accuracy-sweep false-negative — the comment is true but unverified.

**Suggested fix:** Extend the comment-accuracy sweep to flag `always`, `only`, `never`, `must` claims in comments that cannot be matched to an `it` / `test` / `assert` block exercising the exact condition. Particularly watch for type-coercion comments (JSON parsing, Ruby truthiness, Go nil vs zero-value) — these are correct but silently britttle without a pinning test.
