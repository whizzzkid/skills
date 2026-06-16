---
skill: wk-adversarial-review
date: 2026-06-12
type: gap
severity: high
---

Spec routing claims must be cross-checked against authoritative reviewer statements before asserting.

**What happened:** A spec note was added claiming that a specific denial reason bypasses a particular production method call. This directly contradicted a prior authoritative reviewer comment on the same PR that explicitly named which outcomes call that method. The contradiction went undetected until the adversarial subagent caught it on re-review.

**Root cause:** When drafting implementation-routing claims in a spec, the agent relied on logical inference rather than cross-checking the reviewer thread that described the same routing. Authoritative reviewer statements about production code behavior are ground truth that spec prose must not contradict.

**Suggested fix:** Add a sweep step in the comment-accuracy pass: when the diff adds a claim about implementation routing (which method a gate calls, which path bypasses a hook), grep the PR's review thread history for reviewer statements describing the same routing. Any contradiction between the new spec claim and a reviewer's direct assertion about the code is a blocker — the reviewer has read the source, the spec author is inferring.
