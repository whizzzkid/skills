---
class: principle
date: 2026-07-27
severity: medium
---

# A required regeneration can re-stamp host constants — declare it, do not restore

**Rule** — When a diff regenerates a vendored artifact whose content varies by host
platform, name in the commit body: the generator, the platform it ran on, the platform
the committed version came from, and which hunks are platform churn rather than
change-driven. If the pipeline has no verify gate for that artifact class, flag the
missing gate as a follow-up.

**Why** — The neighbouring rule ("restore it to base instead of trusting local
regeneration") covers pollution from *sibling-branch* local state, where the local
result is wrong. This is the opposite axis: the regeneration is **required** (removing a
dependency orphaned a constant five vendored stubs referenced) and the local state is
**legitimate** — the mandated Linux container is what CI matches. Restoring to base would
re-commit the stale macOS-captured values.

Left undeclared, the diff flips a batch of `IS_MAC`/`IS_LINUX`/`IS_BSD` predicates and
adds libc/version constants that have nothing to do with the dependency removal. The new
values are correct, but the hunks read as collateral damage inside an otherwise pure
deletion — a reviewer's only signal is the commit body.

The divergence is invisible because the pipeline verifies one artifact class and not this
one, which is why the follow-up flag is part of the rule and not an aside: an ungated
artifact is how the two platforms silently drifted apart in the first place.

## Placement is the load-bearing part

The bullet sits directly under the base-restore instruction and opens by disclaiming it
("the base-restore above does not apply"). Sited anywhere else, an agent facing a required
regeneration would reach the base-restore rule first and discard correct output.

## Same-pass reclaim

Headroom was 16 B against a 471 B addition. Reclaimed 458 B by dropping the **Example**
column from the inline primary-action emoji table: `references/emoji-cheatsheet.md` is
linked one line below and carries all ten rows with byte-identical examples, so the column
was duplicated by construction. The `Action | Emoji` map — the part actually consulted on
every commit — stays inline; only the illustrations moved. The addition was then tightened
three times rather than widening the hunt. Net **−4 B** (24560 → 24556).

**Where** — `SKILL.md` → "Stage generated artifacts individually", final bullet.
