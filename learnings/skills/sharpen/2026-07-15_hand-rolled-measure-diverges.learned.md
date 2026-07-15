---
skill: wk-sharpen
date: 2026-07-15
type: correction
severity: low
---

Hand-rolled awk to measure SKILL.md body size diverged from the hook and gave a
false over-ceiling reading, despite the existing rule to use the hook's
`measure()` verbatim.

**What happened:** During a size-headroom check I wrote a fresh inline awk that
omitted `state="pre"` in BEGIN. First line hit no branch, fell through to
`body+=n`, so the entire front-matter counted as body — reported body 25239
(−663 headroom, "over ceiling") when the true staged body was 24501 (under).
Re-running with the hook's exact awk gave the correct number.

**Root cause:** Step 7.5 already says "measure with the hook's `measure()`, never
`wc -c` or a fresh awk — a divergent hand-rolled replica reports false headroom."
The rule was not followed; a from-scratch awk was written instead of copying the
hook's function body.

**Suggested fix:** Re-violation of an existing rule → escalate the "use the
hook's measure(), never a fresh awk" bullet one notch, or restructure it to
paste the hook's function verbatim as the only sanctioned command. The failure is
subtle (a missing state init) and self-consistent enough to look plausible.
