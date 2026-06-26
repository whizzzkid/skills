---
skill: wk-sharpen
date: 2026-06-25
type: gap
severity: medium
---

A feedback memory whose core subject is a prohibited/internal term cannot be folded into the public skill repo; scan the subject against `.skillprohibit` at distill time, before byte-budgeting or drafting.

**What happened:** Batch mode surfaced one undistilled feedback memory: "run the local static-analysis reviewer before push." I resolved the target skill, measured the byte budget (19 B headroom), planned a structural reclaim (relocate a sweep row to the extended catalog), drafted the full fold (new sweep row + `allowed-tools` entry + README sync + version bump), staged it — and only then did the staged `grep -iEnf .skillprohibit` reveal the tool's own name is a prohibited term. The entire fold (and the reclaim work) was wasted and had to be reverted.

**Root cause:** The Step 5 "Mechanical overfit scan" greps the *drafted edit text* against `.skillprohibit`, but it runs late — after distill, classify, byte-budget, and draft. The subject term of a learning/memory is knowable at Step 3 (Distill). Nothing told me to test it then. A lesson *about* an internal tool can only ever produce edit text containing that tool's name, so the prohibited-term collision is determinable before any drafting.

**Suggested fix:** Add an early gate (Step 3 Distill, or a new sub-rule before Step 4): grep the source learning/memory's core subject term against `.skillprohibit` first. If it matches, the lesson cannot land in the public skill — route it to the user's private config (`CLAUDE.md`) instead, log the memory as distilled, and skip the fold. Do not byte-budget or draft when the subject is prohibited. (Insertion note: wk-sharpen body is at 24570/24576 B — folding this rule needs a planned structural reclaim of ~its full size first; candidate is relocating a narrow bullet to a `references/` file.)
