---
skill: wk-pr-review
date: 2026-07-28
type: gap
severity: high
verified-against-source: yes
---

Review callers have contradictory ownership rules for adversarial dispatch.

**What happened:** One review skill required dispatching the adversarial gate when no
clearance record existed, while the adversarial and workflow skills explicitly
prohibited review callers from dispatching and treated a missing record as
not-yet-at-gate.

**Root cause:** The caller and callee contracts assign the single-dispatch owner
differently, so following either skill violates the other.

**Suggested fix:** Choose one owner and encode it identically in all three skills:
either review callers only consume existing clearance, or PR review owns a distinct
non-gating adversarial investigation that cannot write the merge-clearance record.
