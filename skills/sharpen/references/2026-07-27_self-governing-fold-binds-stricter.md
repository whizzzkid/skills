---
class: principle
skill: wk-sharpen
date: 2026-07-27
severity: medium
---

**Rule** — when the edit target is a gate, threshold, or budget rule that
arbitrates whether this very fold may land, the fold is bound by the **stricter**
of the pre-edit and post-edit text. A loosened rule takes effect on the next run,
once installed — never on the run that writes it. Record in the run report which
reading was applied.

**Why** — every other fold's rules and its target are independent, so "apply the
skill as written" has one referent. It has two only when the edit rewrites the
gate deciding the edit's own admissibility: the version read at Step 2 and the
version drafted at Step 4. That ambiguity bites *before* the edit lands, so the
general "bump and re-read" instruction never reaches it. The self-governing case
is also where the permissive reading is most attractive and least checkable — a
loosened rule's first beneficiary is the run that loosened it, and the resulting
commit looks fully compliant under its own new text.

The installed-vs-worktree distinction already exists in this skill in the
*punitive* direction (escalation refuses credit for a rule strengthened only in
an uncommitted worktree fold). This is the same distinction applied in the
permissive direction; both say worktree text has not yet steered anything.

**Where** — `SKILL.md` → Step 4 (Draft the Skill Update).

**Self-application (this fold)** — the fold edits Step 4, not the Step 7.5
byte-budget gate that arbitrates its own landing, so the two readings do not
diverge for it. Under the stricter reading (the new rule is a constraint absent
from the pre-edit text), the rule was applied to this run anyway: net measured
non-positive rather than merely under-ceiling.

**Budget** — addition +212 B; reclaims −84 B (the third pointer to
`staged-path-scan.md`, later occurrence in reading order than the one seven lines
above it) and −131 B (Step 8's signing-failure line, stated verbatim by
[`commit-gate.md`](commit-gate.md), whose pointer already sits at the cut site).
Net −3 B. The 1.2× planning ratio (254 B) was not reached: the reclaim pool is
exhausted — every remaining candidate carries a recorded stay-inline or
rejected-relocation note — so the addition was tightened instead, per the
documented fallback. Net non-positive, the binding gate, was met.

**Rejected reclaim targets (do not re-propose)** — the four size ceilings at
Step 7.5, the throwaway-index fence, the overfit-scan stay-inline rows, the
ticket-shape rejection, the reclaim-order forward cross-reference, and the
Source 3 marker-suppression clause: all carry prior recorded stay-inline
decisions.

**Amended 2026-07-27 — "the reclaim pool is exhausted, every remaining candidate
carries a recorded note" is a pool summary, not a per-candidate veto.** It scores
no individual target and states no grounds, so it cannot be retired by evidence
and must not be read as closing the pool. Re-score each candidate individually,
naming the edit shape it is judged under, before recording exhaustion again. The
enumerated rejections above stand on their own stated grounds; the aggregate
sentence does not. See [`byte-budget.md`](byte-budget.md) "A rejection note is a
verdict under an edit shape".
