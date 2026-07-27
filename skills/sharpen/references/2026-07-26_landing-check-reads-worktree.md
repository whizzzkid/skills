---
class: principle
skill: wk-sharpen
date: 2026-07-26
severity: high
---

# A landing check reads the worktree; only escalation evidence reads installed

**Rule** — "Which copy of the skill do I read?" has two different answers, and the file
previously stated only one. Escalation evidence reads the **installed** text (an unshipped
rule cannot have steered the failing run). A **landing-location check** — "did this fold
land?" — reads the **worktree**, where an uncommitted fold lives by definition. Under
divergence the two reads answer different questions and must never be substituted.

**Why** — `SKILL.md` orders a landing confirmation twice (Source 2 "confirm the distilled
principle landed"; Step 7 "re-read the final file end-to-end") without naming a copy for
either, while its single copy-naming rule — the escalation HARD RULE — names `installed`
prominently. A run reaching the landing check finds no governing rule and applies the
nearest one, which governs a different question. The failure is silent and inverts the
verdict: the installed copy legitimately lacks an uncommitted fold, so a *landed* fold reads
as *missing*. The consequence is worse than a wasted check — a fold believed missing invites
a re-fold, and a competing edit entangles a tree that already carries several prepared,
path-disjoint folds.

**Verified against source** — Not taken from the report; the mechanism was confirmed against
the owning text before drafting.

- The three-way divergence was real and load-bearing at distillation time: installed
  **24319 B** / `HEAD` **24528 B** / worktree **25444 B**, all three distinct.
- The escalation rule was read in the **worktree** copy (the loaded skill body is the
  *installed* one, and differs — the same trap the rule addresses). Its scope is set by its
  own heading, `HARD RULE: re-violation escalation`, and by
  [`2026-07-25_escalate-against-installed-text.md`](2026-07-25_escalate-against-installed-text.md),
  whose `Where` places it under that heading. Correct as written, for escalation.
- A content-pinned grep for `installed|worktree` across `SKILL.md` returned exactly **two**
  hits — the escalation rule and the Step 8 report line — so no rule named a copy for the
  landing check. A companion grep for `landed|confirm the distilled|Re-read the final`
  returned the two landing-check sites, neither naming a copy. Both paths were confirmed to
  exist first, so the zero is a real gap and not a mis-resolved path.

**Classification** — `principle`. Generalizes to any skill whose guidance ships through an
install step separate from the repo edit, and whose commit gate can be blocked.

**Escalation** — None. The escalation rule did not fail; it fired correctly for its own
question. Nothing governed the landing check, so this is a gap, not a re-violation.

**Placement** — Folded as a trailing clause on the escalation rule rather than at either
landing-check site: that is where the misapplication originates (the reader reaches for the
nearest copy-naming rule), it bounds the existing rule and states the correct target in one
edit, and it precedes both landing-check sites in reading order.

**Rejected reclaim targets (do not re-propose)** — The pattern-file / engine-divergence
rationale at the Step 5 hook-vs-hand-roll bullet: its wording is a deliberate recorded choice
per [`2026-07-25_same-flags-not-same-engine.md`](2026-07-25_same-flags-not-same-engine.md),
which rejects leading with the conditional framing, so tightening it would reinstate a
disproven mechanism. The batch-mode drain-canary bullet's symlink blind-spot clause: grepped
against every linked reference and stated in **none** of them, so it is a failure-mode
explanation with no duplicate to cut.

**Arithmetic for this fold** — Pre-edit body **24442 B** against a 24576 B ceiling — **134 B**
headroom, measured by driving the size hook's `measure()` verbatim through a throwaway index
copy (the real index holds another fold's staged paths). Step 5 audit run **before** the
budget locked: all 12 reference links resolve, no dead labels, no in-file contradiction to
repair, and every cleanup item — this record, the README `Version:` bump, the learning rename
— lands outside the ceiling-bound file. **Measured allowance: 0 B, not 300 B.**

Addition **+88 B** (one trailing clause), tightened down from a ~130 B draft that spelled out
the contrasting question inline. Reclaim **0 B**: the pool is exhausted and every remaining
candidate carries a recorded stay-inline or rejected-relocation note, re-verified above rather
than assumed. Net **+88 B**; body **24442 → 24530 B**, clearing the ceiling with 46 B spare.

Net non-positive was **unreachable** at an exhausted pool. Per the exhausted-pool rule the
*addition* was tightened instead of widening the hunt into protected content, and the
arithmetic is reported rather than the fold abandoned. Every ceiling is clear.

**Where** — `SKILL.md` → Step 3, re-violation escalation HARD RULE, appended to the
installed-text bullet.
