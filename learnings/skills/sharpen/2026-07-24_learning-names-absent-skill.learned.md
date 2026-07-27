---
skill: wk-sharpen
date: 2026-07-24
type: gap
severity: medium
verified-against-source: yes
---

A learning's `skill:` field can name a skill that has no on-disk directory; Step 2 needs
to route by subject in that case, not treat it as a missing target.

**What happened:** A batch-mode item arrived with a frontmatter `skill:` naming a generic
shell/interpreter name. No directory of that name exists under `skills/` — the tree has a
workstyle sub-skill that owns that language's conventions instead. Step 2's dir-resolution
rule (glob `skills/*"${n#wk-}"`) returns nothing, and the rule as written only warns
against *transforming* the display name; it does not say what to do when the listing comes
back empty. The subject grep called for by the same step is what actually resolved it: the
lesson's mechanics belonged to the language's workstyle skill, and a second skill carried a
consuming instance of the same defect, both folded in one pass.

**Root cause:** Step 2 conflates two distinct failures. It handles "the dir name is not a
mechanical transform of `name:`" but not "no dir corresponds to this name at all" — which
is the normal case for a learning filed against a tool, language, or interpreter rather
than against a skill. The empty glob then reads like the mis-resolution the rule already
warns about, and the adjacent rule about a zero-match grep being "unverified until the path
is confirmed to exist" pushes toward re-checking the path instead of abandoning it. Nothing
says the `skill:` field is a *reporter's guess at ownership*, subordinate to the
subject-grep result.

**Suggested fix:** State that the `skill:` field names a suspected owner, not a resolved
target: when the glob finds no dir, do not retry or report a gap — fall through to the
subject grep and route to the skill whose body owns the mechanics (for a
tool/language/interpreter lesson, that is the corresponding `wk-<tool>` or workstyle
sub-skill). Keep the existing "correct every over-general instance elsewhere" clause
pointed at the consuming skills the same grep surfaces. Note that the learnings-dir
convention (never prefixed, always created on demand) means an unresolvable `skill:` value
is expected input, not malformed input.
