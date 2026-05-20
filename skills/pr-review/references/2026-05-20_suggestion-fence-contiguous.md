---
name: suggestion-fence-contiguous
description: A single suggestion fence must target one contiguous range; multi-site fixes need separate anchors.
class: principle
---

- **Rule:** Before drafting a ` ```suggestion ` fence, verify the
  fix targets a single contiguous range. Multi-site fixes split
  into one anchored comment per site, or drop to a plain language
  fence describing the change in prose.
- **Why:** GitHub applies a suggestion as a single hunk replacing
  the anchored range. A fence whose body implies changes at two
  separate locations is silently misapplied (only the contiguous
  range is replaced), leaving the comment misleading.
- **Where:** Phase 5, "Use applicable suggestion blocks" rules,
  new bullet after the multi-fence allowance.
