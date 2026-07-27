---
class: principle
---

# A control target must be able to produce a hit under the scan's own form

**Gap** — Batch mode already required a positive control before a hand-rolled zero could
close out a source ("never let a zero close out a source until a positive control moves its
count"), but nothing constrained how the *control target* is chosen. A control aimed at a
structurally-unhittable target cannot move off zero for any input, so it satisfies the
letter of the rule while carrying no evidence — and its zero is byte-identical to a
confirmed drain.

**Verified against source** — Reproduced this run rather than taken from the report. At the
installed-skills root, `find <root> -mindepth 2 -type f` returns `0` while `find -L` over
the identical root returns `940`, with 64 symlinked entries at depth 1: `find` does not
descend a symlinked directory. The reported framing was **sharpened** in the process — the
global learnings inbox itself is a real directory, so a probe rooted *there* is sound; the
dead control came from rooting the probe one level up, in the symlink-composed parent. The
fold was therefore re-derived from the traversal semantics rather than from the report's
"the inbox is symlinked" wording.

**Principle** — Choose a control target by structure, not by topical proximity to the scan.
A traversal primitive that silently skips a class of node returns zero for any content when
rooted where those nodes live. Re-prove with a mechanism that does not share the scan's
blind spot: plant an in-place canary inside the scanned tree and re-run the *identical*
invocation form, then corroborate with a primitive that resolves what the scan skips.

**Where** — `SKILL.md` → Batch Mode preamble, so it governs all four sources rather than
Source 3 alone. Placed at the first point a run reaches before any source scan; the Source 3
"unanimous verdict" bullet kept its distinct rule and shed its now-duplicated second
sentence, which the linked `memory-marker-diff.md` states in full.

**Escalation** — None. The existing control rule was not re-violated; it was under-specified.
No prior rule constrained control-target selection, so this is a new constraint rather than
a repeat, and the positive-steering exception does not apply either way.

**Rejected suggestion (do not re-propose)** — Did not weaken the Step 3 inline canary hint
("expand a denylist pattern to a literal it matches") to buy bytes. That construction step is
exactly where this run's own control died — a mangled expansion produced a false-dead canary
— so the actionable half stays inline; only the anti-pattern clause, stated in full in
`staged-path-scan.md`, was trimmed. Also honored the two standing rejections in
`2026-07-25_reclaim-search-order.md`: the throwaway-index fence and the overfit-scan
stay-inline rows were left untouched.

**Arithmetic for this fold** — Addition 488 B (487 B bullet + 1 B blank) against six reclaims
netting 502 B (99 + 128 + 162 + 29 + 28 + 56), all located by the "inline clause under a
linked pointer" rule: body 23989 → 23975 B, net **−14 B**, every ceiling clear. The 1.2×
planning ratio against fold-plus-300 B allowance was unreachable without cutting load-bearing
rules; per the binding-gate rule the arithmetic is reported and the hunt was not widened.

**Measurement defect caught by the measure-once step** — The first budget claimed net −1 B and
was wrong by 42 B: one reclaim's *old* size was read with `sed -n '<n>p'` using a line number
taken from an earlier, differently-numbered read, so a neighbouring line was measured instead
of the target (222 B reported as 264 B). The staged measure disagreed with the predicted net,
and reversing the edits on a temp copy localized it. **Size a reclaim by matching its content,
never by a line number carried across reads** — line numbers go stale the moment anything is
inserted, and the resulting error is silent and self-consistent. The overrun was discharged as
the rules prescribe: one decisive cut from target #1, not a nibble hunt.
