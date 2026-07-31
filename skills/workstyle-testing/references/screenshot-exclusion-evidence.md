---
class: principle
date: 2026-07-28
severity: medium
---

# Prove screenshot exclusion with decoded pixels

**Rule:** Compare decoded pixels against a manually excluded baseline and
include a negative control where the UI remains visible. Use `display: none`
when temporary exclusion must suppress the whole subtree.

**Why:** A descendant can override an ancestor's `visibility: hidden` and still
paint. Encoders can also emit different image bytes for pixel-identical output,
so encoded-byte equality is stricter than the behavior under test.

**Where:** Screenshot-capture tests that assert owned UI is absent from an
image. Computed ancestor visibility is diagnostic evidence, not proof of the
rendered result.
