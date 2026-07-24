---
class: principle
---

# Byte-budget mechanics (Step 7.5)

Full mechanics for the size-ceiling budget. The imperatives live in `SKILL.md`;
this file carries the exact procedure and the failure modes behind each rule.

## Measuring the staged body

- **Run the hook's `measure()` verbatim.** Copy it from `.githooks/check-skill-size.sh`.
- `git add` the file first — `measure()` reads `git show ":<path>"`, the staged blob,
  never the working tree. A working-tree measure judges bytes you are not committing.
- Run it twice: once pre-draft (to learn headroom) and once at commit (to confirm).
- **Never `wc -c` a whole `SKILL.md`.** It counts front-matter as body and overstates.
- **Never abbreviate the awk.** Dropping its `state="pre"` init counts front-matter as
  body → a false, *self-consistent* over-ceiling headroom that looks plausible and is wrong.

## Stating the budget as arithmetic

- Byte-measure the **draft**, not just the target: write the addition to a scratch file
  and `LC_ALL=C wc -c` it. That is correct for a bare fragment, never for a `SKILL.md`.
- For a rewrite-style reclaim, measure the replacement and net it `old - new`.
- Write the numbers down: addition, each reclaim's net, the total.
- A budget that cannot be stated as arithmetic has not been computed. Estimating either
  side of a two-digit margin is a coin flip.

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
- Reserve prose-tightening for the final margin.
