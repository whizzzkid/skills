---
class: principle
---

# A fold applied under a blocked gate needs its own terminal bucket

**Rule** — Batch mode's terminal-state vocabulary carries three buckets, not two: processed,
unclaimed backlog, and **distilled-not-landed**. A fold that is applied to the worktree but
cannot be committed belongs in the third: leave the source learning unrenamed and name the
item in the report.

**Why** — The two-bucket vocabulary forces a mis-report whenever a commit gate is blocked, and
both directions lose information the next run needs:

- Reported *processed* → the rename implies the fold shipped, and an unlanded worktree edit
  becomes invisible to the run that would otherwise land it.
- Reported *unclaimed backlog* → the next run reads the item as unfolded and opens a second
  fold on a path that already carries one, which the ownership rule explicitly forbids.

The rename-after-landing rule already existed; what was missing was the *state name* for the
interval between applying and landing, which is exactly the state a blocked gate produces.

**Verified against source** — The source learning's headline claim was checked first and
**did not hold**: it reported that the deferral rule fails to distinguish a newly-dirtied clean
path from an already-dirty one, but the worktree already states the qualified two-case split
verbatim. Classified `already-covered (unshipped)` for that claim — the installed skill still
carries the old blanket wording while the worktree carries the qualification (divergence
confirmed by diffing the two, and the committed tip carries neither), so the rule never steered
the reporting run and **no escalation notch was spent**. Only the learning's subordinate
reporting clause survived as a genuine gap; absence confirmed by literal-match grep with
known-present controls in the identical invocation form.

**Classification** — `partial` → `principle`. Generalizes to any queue whose processed-marker
is tied to a commit that an unrelated global failure can block.

**Escalation** — None. The installed-vs-worktree precondition governs, and the surviving gap is
newly stated rather than a rule that fired and failed.

**Rejected reclaim targets (do not re-propose)** — No new relocation was proposed. The category-1
pool (an inline rule ending in a `references/…` pointer) is exhausted: every such bullet was
already trimmed by earlier passes, and the remaining candidates carry recorded stay-inline
decisions — the Step 3 `command`-prefix parenthetical (the site fix a high-severity fold exists
to place *at* that gate), the throwaway-index fence, the overfit-scan procedure rows, and the
Source 3 marker-suppression clause, which this run itself relied on to confirm the two
non-memories were excluded by the parse gate rather than silenced by a marker entry.

**Arithmetic for this fold** — Replacement net **+137 B** (435 B new for 298 B old), which already
absorbs ~47 B reclaimed from a proven later-duplicate: the bullet restated "unclaimed backlog for
the dispatcher", stated earlier at the ownership rule. Body 24065 → 24202 B against the 24576 B
ceiling, leaving 374 B; front-matter 1003/8192, `description:` 466/1024, `allowed-tools:` 8/36.
The up-front reclaim regime **did** trigger (headroom 511 B under 2× the 437 B fold-plus-allowance)
and its 1.2× target — 524 B — was **unreachable at zero coverage risk**. Per the binding-gate rule,
the arithmetic is reported rather than the hunt widened into load-bearing content: net is positive,
not non-positive, and every ceiling stays clear. A future pass reclaiming here must find a *new*
duplicate, not revisit the protected list above.

**Where** — `SKILL.md` → Batch Mode → Source 2, the mtime/ownership bullet's terminal-state
sentence.
