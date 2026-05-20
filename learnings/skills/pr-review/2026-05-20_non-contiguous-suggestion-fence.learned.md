---
skill: wk-pr-review
date: 2026-05-20
type: gap
severity: low
---

Suggestion fence used for a multi-location fix, which GitHub cannot apply.

**What happened:** Proposed a fix that required changes on two non-adjacent lines (an array declaration and its expansion site). Wrapped the first line in a `suggestion` block. The second change was described in prose — inconsistent presentation and the suggestion itself was misleading.

**Root cause:** Skill says to use suggestion fences for concrete replacements, but doesn't call out that the replaced lines must be contiguous. A fix spanning two separate locations cannot be expressed as a single suggestion block.

**Suggested fix:** Before drafting a `suggestion` fence, verify the fix targets a single contiguous range. If the fix requires changes in two separate locations, use two separate comment anchors (one per site) or describe both in a prose code block rather than a suggestion fence.
