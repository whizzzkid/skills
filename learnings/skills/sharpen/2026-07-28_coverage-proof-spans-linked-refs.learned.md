---
skill: wk-sharpen
date: 2026-07-28
type: gap
severity: low
verified-against-source: yes
---

An `already-covered` verdict's proof can span `SKILL.md` plus its linked references, but
the full-read gate names only "the full file".

**What happened:** A learning reported a reclaim-gate behavior and proposed a conditional
fix. Establishing `already-covered` at the rule level (not the topic level) took four
citations, and only two of them lived in `SKILL.md`; the other two — the pool-summary
classification and the note-authoring requirement, the latter being the exact rule the
report's proposed fix named — lived solely in a curated reference `SKILL.md` links. Reading
the linked reference was what made the verdict defensible rather than a topic-level match.
The gap did not bite: the `SKILL.md` bullet alone happened to carry the deciding rule, so a
`SKILL.md`-only read would have reached the same verdict here for weaker reasons.

**Root cause:** Confirmed by reading both files and locating each cited rule. Step 2 says
"read the entire `SKILL.md`", and Step 3's full-read HARD RULE says "reading the full file"
— singular, and in context that reads as the skill body. Neither extends the read to the
references the body links. But the de-bloat pass deliberately *moves* full statements out of
`SKILL.md` into linked references and leaves a compressed inline clause plus a pointer, so
the more a skill has been de-bloated, the more of its coverage sits behind pointers by
construction. The two gates therefore pull against each other: de-bloat relocates the proof,
and the coverage gate never follows it.

The converse direction is already handled — the reclaim guidance states that only a *linked*
reference proves coverage, since a per-learning distillation record is never linked and so is
absent at runtime. That rule is scoped to choosing reclaim targets, not to classifying a
learning, so nothing carries it across.

**Suggested fix:** Extend the full-read gate so the coverage surface is the skill body plus
every reference it links, and require each `already-covered` citation to name which of the
two it came from. Reuse the existing linked-vs-unlinked distinction rather than restating it:
a citation resolving only to an unlinked per-learning record proves nothing at runtime and
makes the item `partial`, not covered.
