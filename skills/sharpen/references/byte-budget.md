---
class: principle
---

# Byte-budget mechanics (Step 7.5)

Full mechanics for the size-ceiling budget. The imperatives live in `SKILL.md`;
this file carries the exact procedure and the failure modes behind each rule.

## The ceilings

`.githooks/check-skill-size.sh` blocks a commit breaching any of these (each
env-tunable, so a deliberate exception needs no hook edit):

| what | ceiling | env var |
| --- | --- | --- |
| **Body** (everything after the front-matter) | ≤ **24576 bytes** | `SKILL_SIZE_MAX_BYTES` |
| **Front-matter** block | ≤ **8192 bytes** | `SKILL_FRONTMATTER_MAX_BYTES` |
| **`description:`** field | ≤ **1024 bytes** | `SKILL_DESC_MAX_BYTES` |
| **`allowed-tools:`** list | ≤ **36 lines** | `SKILL_TOOLS_MAX_LINES` |

## Measuring the staged body

- **Run the hook's `measure()` verbatim.** Copy it from `.githooks/check-skill-size.sh`.
- `git add` the file first — `measure()` reads `git show ":<path>"`, the staged blob,
  never the working tree. A working-tree measure judges bytes you are not committing.
- **Partitioned index → stage into a throwaway index copy, not the real one.** When the
  index already holds another run's path-scoped fold, `git add`-ing yours destroys that
  separation. Copy the index and point git at the copy (`GIT_INDEX_FILE`), then run
  `measure()` **entirely unmodified** — `git show ":$1"` resolves through the copy, so the
  staged-blob read stays real. Prefer this over swapping the blob source for `cat`: any
  edit to `measure()` forfeits the "verbatim" guarantee the rules below depend on.
  `unset GIT_INDEX_FILE` afterward or every later git call silently uses the copy.
- Run it twice: once pre-draft (to learn headroom) and once at commit (to confirm). The
  pre-draft measure is unconditional, never gated on the file "looking tight" — the
  at-ceiling state is invisible until measured, and a fold drafted blind is already spent.
- **Never `wc -c` a whole `SKILL.md`.** It counts front-matter as body and overstates.
- **Never abbreviate the awk.** Dropping its `state="pre"` init counts front-matter as
  body → a false, *self-consistent* over-ceiling headroom that looks plausible and is wrong.

## Stating the budget as arithmetic

- Byte-measure the **draft**, not just the target: write the addition to a scratch file
  and `LC_ALL=C wc -c` it. That is correct for a bare fragment, never for a `SKILL.md`.
- For a rewrite-style reclaim, measure the replacement and net it `old - new`.
- **The priced pair must BE the applied pair — slice `old` out of the file, never retype it.**
  Retyping is not itself the defect (a careful retype can come out byte-identical); the defect
  is pricing one edit and applying another. Price a whole line, then apply an edit that
  replaces only the middle of that span, and the budget is wrong by the untouched remainder —
  a measured 50 B error on a 124 B line whose real saving was 6 B. The editing tool cannot
  catch it: it never saw the priced string. Extract both sides with
  `sed -n '<n>p' <file> > old.txt`, feed those exact bytes to the editor, and the two edits
  cannot diverge.
- **A hand-composed delta is an estimate to reconcile, never the budget itself.** If it
  disagrees with the single verbatim `measure()`, re-tighten until they agree — at near-zero
  headroom the slip surfaces only at the commit hook, after the fold is written and versioned.
- **Address a reclaim by its content, never by a line number carried across reads.** Line
  numbers go stale the moment anything above them shifts, and a compressed or partial read
  renumbers silently — `sed -n '<n>p'` then measures a *neighbouring* line and the budget is
  wrong by that line's size while still summing perfectly. Pin the old size with the same
  match that will locate the edit (`grep -n '<literal>'` → measure the line it returns).
- **A staged measure that disagrees with the predicted net is a real defect, not rounding.**
  Localize it before proceeding: copy the file, reverse the edits, and re-measure — the
  reconstruction's agreement with the original baseline proves which side is wrong.
- Write the numbers down: addition, each reclaim's net, the total.
- A budget that cannot be stated as arithmetic has not been computed. Estimating either
  side of a two-digit margin is a coin flip.
- **Include an audit-cleanup allowance in the addition** (~25% of the fold, floor ~300 B).
  Step 5 mandates resolving contradictions and bundling cleanup into the same change, and
  those bytes are *discovered* after the budget locks — the fold that introduces a
  contradiction is precisely the one whose cleanup could not be foreseen, so that ordering
  guarantees the overrun rather than merely permitting it.
- **But the ordering is a default, not a constraint — so the allowance is an estimate for
  cleanup you have not measured yet, never a fixed reserve.** Run the Step 5 audit *before*
  the budget locks and the allowance becomes a measurement: count the cleanup bytes that
  actually land **inside the ceiling-bound `SKILL.md`**. A measurement *replaces* the
  estimate; it never adds to it.
  - **Cleanup landing outside the ceiling-bound file costs zero against the budget.** Per-learning
    distillation records, linked `references/` files, a sibling `README.md` `Version:` bump and any
    newly created reference carry no ceiling — so a measured allowance is frequently **0 B**, not 300 B.
  - **Under tight headroom, auditing early is the preferred move.** It converts an estimate
    into a measurement, which is the cheap way out of a standoff where the fold plus a
    reserved allowance exceeds headroom and the reclaim pool is exhausted. The alternative —
    widening the hunt until it reaches load-bearing content — trades a correctness property
    for a byte count, and the ceiling never outranks a load-bearing rule.
  - Reserve the ~25%/floor-300 B estimate only while the audit is still outstanding.
- **The binding gate is: net non-positive AND every ceiling clear.** The ≥1.2× reclaim
  ratio is a planning target, not the gate. When post-draft cleanup pushes the ratio under
  1.2× while net stays non-positive and the body stays under ceiling, report the arithmetic
  and stop — a second reclaim hunt at that point only endangers load-bearing rules.
- **Never buy the ratio back by moving a gate's checks or a verification checklist behind
  a pointer.** That trades a correctness property for a byte count.

## Measuring exactly once

- Stage the addition **and** the reclaim cuts together, then measure **once**.
- Multibyte characters inflate the count — a `→` is 3 bytes, not 1.
- A second measure-and-trim cycle is the re-violation signal. Stop and re-plan with one
  decisive structural cut, not another prose nibble.

## Choosing reclaim targets

- Count reclaim **NET**, never gross.
- A prose-block relocation nets gross MINUS the stub it leaves (heading + pointer +
  sentence). The stub dominates a short block → prefer a LARGE block.
- A row/bullet merge nets ~3 B unless it also drops the now-duplicated phrase.
- Deleting a provably-duplicated rule nets its full size — do it with zero replacement;
  a cross-reference back re-spends the reclaim.

### Where to look, in order

1. **An inline rule that ends in a `references/…` pointer.** The pointer is itself evidence
   a fuller statement exists elsewhere; open that reference — states the rule in full →
   the inline clause is deletable at full value with zero replacement and zero coverage
   risk. This is the highest-yield target and the cheapest to prove, so search it first.
   The split is by design where a reference says the imperatives live in `SKILL.md` and it
   carries the procedure and failure modes — any failure-mode rationale left inline under
   such a pointer is duplicated by construction.
2. **Scaffolding and dead labels** — delete outright.
3. **Relocation of a narrow catalog block** — only after 1 and 2 are exhausted, and only
   for a LARGE block (the stub dominates a short one).
4. **Prose-tightening** — the final margin only, never the search.
5. **The draft itself**, once 1–4 are exhausted and net is still positive. Every target
   above lives in the file's *existing* content, so an exhausted pool reads as "stop or
   widen the hunt" — but the addition is a free variable too, and the only one that cannot
   endanger a load-bearing rule. Audit the draft for:
   - a clause restating a rule stated in an adjacent bullet (the body already says "state
     a rule once; cross-reference instead of restating");
   - enumerated examples, worked arithmetic, or failure-mode rationale that belong behind
     an **already-linked** pointer, where they cost zero ceiling bytes.
   - Both cuts preserve coverage. Trimming a rule, an error code, or a failure mode to fit
     is still forbidden — this shrinks restatement and relocates detail, never coverage.
   - **A draft's size is an estimate, not a requirement.** Nothing about a first draft's
     wording is load-bearing until it lands, so rewriting it shorter is always available and
     always cheaper than the alternatives.

- **Only a *linked* reference proves coverage.** A per-learning distillation record is never
  linked from `SKILL.md`, so text surviving only there is absent at runtime — deleting an
  inline rule against one silently drops it.
- **Grep `references/` for a recorded stay-inline / rejected-relocation note before
  proposing any relocation.** Ceiling pressure otherwise argues for exactly the move the
  skill's own history already rejected, and the note is the only thing preventing a later
  pass from undoing a deliberate decision. A note covering a block you still intend to move
  is a decision to reopen explicitly, not to route around.
