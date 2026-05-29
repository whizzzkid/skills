---
skill: wk-adversarial-review
date: 2026-05-22
type: gap
severity: medium
---

When a value is computed and stored regardless of which branch the code takes, tests that only cover the "interesting" branch miss the symmetric happy path.

**What happened:** Tests for a Result struct's `bucket` field covered three blocked/disabled cases but not the in-rollout allowed case. A short-circuit regression that only computed `bucket` when the gate fires would silently slip through — all three written assertions would still pass.

**Root cause:** Writing tests for a "new field on a struct" naturally biases toward the interesting failure cases (nil, edge values, blocked path) and skips the boring happy path where the field is populated but the gate decision is "allowed." The adversarial-review subagent caught this on a probe; mechanical sweeps did not.

**Suggested fix:** Extend Step 4's "Categories to hunt" subagent prompt with: when a new field is populated unconditionally in a method that has both pass/fail return paths, demand assertions on the field for at least one assertion of each return path. Detection at the prompt level (not a grep) — the subagent already inspects new fields; bias it to ask "is this value tested on both the success and failure paths?"
