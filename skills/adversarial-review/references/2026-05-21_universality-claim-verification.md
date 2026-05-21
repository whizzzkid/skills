---
name: universality-claim-verification
description: Verify spec prose claims like "common to every X" against actual call sites.
class: principle
---

- **Rule:** Grep spec docs for universality phrases ("common to
  every", "tagged on all", "present in every", "applies to every").
  For each hit, extract the subject noun, grep the diff for every
  call site of the related class/function, and verify the claimed
  field is passed at every site.
- **Why:** Universality claims are hidden enumerations that
  count-based and bullet-based greps miss. Spec-vs-implementation
  divergence on a "common to every" claim is a blocker class that
  bots catch post-push but mechanical sweeps miss pre-push.
- **Where:** Sweep 2.8 (Cross-doc enumeration sync),
  "Universality-claim verification" block.
