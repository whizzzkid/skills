---
class: principle
---

**Rule:** When the diff touches a Markdown doc with intra-doc anchor links to
emoji/punctuation-prefixed headings, the anchor sweep must replicate GitHub's
exact slug algorithm: lowercase → strip emoji/punctuation/variation-selectors →
spaces to hyphens → **trim leading/trailing hyphens** → preserve internal
multi-hyphens (` — ` renders as `--`; do NOT collapse). Cross-check against the
doc's own rendered table-of-contents links as ground-truth anchor form rather
than re-deriving from scratch.

**Why:** A presence-only "anchor refs vs headings" compare misses two real
break modes: a `(#-heading)` link (leading hyphen the author guessed the emoji
leaves but GitHub trims) silently 404s, and a naive `\s+`→single-hyphen
validator false-positives on legitimate `#d1--…` links from ` — `.

**Where:** Step 2 Mechanical Sweep Catalog — row 2.35 (extended catalog).
