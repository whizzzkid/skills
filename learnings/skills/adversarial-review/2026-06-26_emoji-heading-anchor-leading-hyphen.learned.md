---
skill: wk-adversarial-review
date: 2026-06-26
type: gap
severity: medium
---

Hand-written intra-doc anchor links to emoji-prefixed Markdown headings break when they carry a leading hyphen.

**What happened:** A spec added two cross-reference links to a `## 🗃️ Data Model` heading written as `(#-data-model)` (leading hyphen). GitHub's anchor generator strips the emoji AND the resulting leading separator, so the real anchor is `#data-model` — the `(#-data-model)` links silently 404 within the rendered doc. The mechanical sweep that lists "anchor refs used" vs "headings" did not flag it because it only compared presence, not the leading-hyphen normalization.

**Root cause:** GitHub slugifies headings as: lowercase → strip non-word chars (emoji, punctuation, variation selectors) → spaces to hyphens → **trim leading/trailing hyphens**. An author seeing `🗃️ Data Model` reasonably guesses the emoji leaves a leading separator, but GitHub trims it. A naive validator that collapses `\s+` to a single hyphen also mis-handles ` — ` (em-dash with surrounding spaces), which GitHub renders as a double hyphen (`--`) — producing false-positive "missing anchor" reports for legitimate `#d1--…` links.

**Suggested fix:** When the diff touches a Markdown doc with emoji-prefixed headings and intra-doc anchor links, the anchor sweep must replicate GitHub's exact slug algorithm: strip emoji/punctuation, **trim leading/trailing hyphens**, and preserve internal multi-hyphens (do NOT collapse `--` from ` — `). Cross-check by matching the doc's own table-of-contents links (already-rendered convention) as the ground-truth anchor form rather than re-deriving from scratch.
