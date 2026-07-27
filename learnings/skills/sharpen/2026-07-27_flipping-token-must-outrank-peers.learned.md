---
skill: wk-sharpen
date: 2026-07-27
type: gap
severity: medium
verified-against-source: yes
---

An uppercase-initial control entry only flips collation order if its letter also sorts
after its lowercase peers — otherwise the arms agree and the control is dead.

**What happened:** Building the Source 3 disagreement control, the order-flipping entry was
sited correctly as a matched pair present on both sides, against a truth of zero, with one
input sorted under the ambient UTF-8 locale and the other under `C`. It was still dead: the
two sorts produced byte-identical order and both arms returned zero. The chosen token began
with an early-alphabet capital while every real entry began with a lower-case letter later
in the alphabet, so the capital sorted first under **both** collations — `C` puts it first
because uppercase precedes lowercase, and the case-insensitive collation puts it first
because its letter is alphabetically first. Re-choosing the token so its letter fell after
the peers' initials made the sorts diverge, and the unpinned arm then emitted the expected
phantom row while the pinned arm returned zero.

**Root cause:** The reference states the disagreement is case ("C orders an uppercase-initial
name before lowercase-initial ones, UTF-8 after") and warns that mixed case is necessary but
not sufficient — but the stated insufficiency is about *siting* (which stage is unpinned,
matched pair vs one-sided row). It never says the flip also depends on the token's letter
relative to its peers. Read as written, "add a mixed-case entry" is satisfied by a token
that cannot flip anything, and the resulting dead control presents exactly like a live one:
the arms agree, which the existing tripwire reads as "rebuild the control" without saying
which property to change.

**Suggested fix:** Add the token-selection rule alongside the siting rule: the flipping
entry must be uppercase-initial **and** its initial must sort after the initials of the
lowercase entries it is interleaved with, since the two collations only disagree where the
case ordering and the alphabetical ordering pull in opposite directions. Note the concrete
diagnostic — compare the two sorted inputs directly and require them to differ before
looking at the arms at all, because identical sorts prove the token is wrong while
identical arms alone do not say why.
