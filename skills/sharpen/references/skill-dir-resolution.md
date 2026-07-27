---
class: principle
---

# Resolving a skill's on-disk directory (Step 2)

**Rule** — Resolve the skill directory by listing/globbing the tree, never by
transforming the display name. Treat a zero-match grep whose emptiness is
load-bearing as unverified until the target path is confirmed to exist.

**Why** — Directory naming is not invariant with the `name:` frontmatter field.
The dominant convention drops a leading `wk-`, but at least one shipped skill
directory keeps it, so a blind strip and a blind reuse each mis-resolve some
skill. A mis-resolved coverage grep returns zero matches, which is
indistinguishable from a genuine gap — it inverts the `already-covered`
decision, so an existing rule reads as absent, the fold duplicates it, and the
re-violation escalation is skipped because the baseline rule appears not to
exist. Missing-path warnings cannot be relied on as the signal: grep
implementations differ in whether they emit one, and a wrapper or alias can
suppress it.

## An empty listing is expected input, not a failure

Learnings directories are created on demand and are never `wk-`-prefixed, so a
`skill:` value that resolves to nothing is normal. Treat the field as the
reporter's *guess* at ownership and route by the subject grep instead. Never
retry the path or file the miss as a gap.

**Where** — Step 2 (read the full skill), before any cross-skill coverage sweep.
Also applies to the canonical-path rule in the learnings-capture skill, whose
strip is correct for its own directory but must not be reused as a `skills/`
path.

## Rejected suggestion

The field report proposed stating the target as
`skills/<name-without-wk->/SKILL.md` — i.e. encoding the strip as the rule.

**Rejected:** the report's premise ("the on-disk directory never carries the
prefix") is disproved by the tree; a shipped, tracked skill directory carries
it. Encoding the strip would silently mis-resolve that skill and reproduce the
same zero-match failure with inverted polarity. Resolution by listing handles
both naming forms and needs no premise about the convention.
