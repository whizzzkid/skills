---
class: principle
---

# Cut needle and control from opposite sides of the change

**Rule** — when verifying that a fold landed, cut the **needle from the changed
span** and the **control from a span the change left untouched**, and
length-guard both against a minimum width. A control cut blindly from a
pre-change revision is stale by construction whenever the fold under test edited
that region; a needle cut from a fixed offset can land in the *unchanged
remainder* of a changed line and prove nothing.

**Why** — the existing rule says a failed positive control indicts the control,
but never says how to *select* one, so selection stayed ad hoc. Blind selection
produces two symmetric false verdicts that both look like real findings:

- **Stale control** — cut from a region the fold rewrote, it scores ABSENT and
  the haystack momentarily reads as unreadable. A prior run cut 14 candidates
  blindly and got only 6 usable. With fold-modified lines excluded and a 20-byte
  guard applied, selection went to **9 usable / 0 stale**.
- **Needle in the untouched remainder** — a fixed-offset cut from a *modified*
  line can fall entirely inside text the fold did not touch, scoring PRESENT and
  reading as "did not land". Reproduced here: one landing site scored a false
  NOT-LANDED at offset 60 and scored LANDED once needles were slid across the
  whole line. This is the mirror image of the byte-budget warning about measuring
  a whole span when the edit replaces only its middle.

Length-guarding is not optional on either side: an empty cut scores a false PASS
under `grep -qF ''` and a false MISSING under `grep -qFf -`. Short lines silently
yield sub-guard cuts at a fixed offset — seven control candidates and one needle
fell below the guard here.

**Also observed (harness, not selection)** — the controls earned their keep by
catching a defect in the probe itself: `cut -c` under `LC_ALL=C` split multi-byte
characters, the ambient-UTF-8 `grep` then failed with *illegal byte sequence*, and
the probe counted that **rc=2 error as rc=1 "absent"**. Three controls falsely
read LANDED. Discriminate `rc=0` / `rc=1` / `rc>=2` explicitly and pin `LC_ALL=C`
on the matcher as well as the cutter — an errored match is not a negative match.
Without controls this would have silently corrupted the needle verdicts too.

**Where** — `SKILL.md` → Step 1 → *HARD RULE: the report is a hypothesis* → the
deterministic-artifact bullet, appended to the clause on what a failed positive
control indicts.
