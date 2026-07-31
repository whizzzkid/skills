---
skill: wk-workstyle-testing
date: 2026-07-28
type: surprise
severity: medium
verified-against-source: yes
---

Screenshot exclusion tests must compare decoded pixels, not encoded image bytes or computed ancestor
visibility.

**What happened:** A capture helper set `visibility: hidden !important` on an overlay host, while a
descendant explicitly set `visibility: visible`. The descendant still painted. Comparing decoded
RGBA pixels localized the unexpected output to the overlay, while PNG-byte comparison also changed
for pixel-identical images and was too strict.

**Root cause:** CSS visibility permits a descendant to become visible under a hidden ancestor, and
image encoders can produce byte-distinct files for the same decoded pixels.

**Suggested fix:** When testing that owned UI is absent from a screenshot, compare decoded pixels
against a manually excluded baseline and include a negative control where the UI is visible. Prefer
`display: none` for the temporary exclusion when descendants must not override it.
