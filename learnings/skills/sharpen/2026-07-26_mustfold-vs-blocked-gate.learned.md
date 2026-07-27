---
skill: wk-sharpen
date: 2026-07-26
type: gap
severity: medium
verified-against-source: yes
---

The "a blocked commit gate defers a MUST-FOLD item" rule does not distinguish opening a *new*
unlandable fold from extending one that is already uncommitted on the same path.

**What happened:** A `severity: high` item arrived while commit signing was down. Two rules in
`SKILL.md` pointed opposite ways: MUST-FOLD says land the lesson in `SKILL.md`; the ownership
bullet says a blocked commit gate defers a MUST-FOLD item because "an unlandable fold entangles
a shared tree." The tree already carried a prepared, uncommitted fold for this same skill
touching the very reference file the lesson concerned.

**Root cause:** The deferral rule is written against the *marginal* entanglement of adding a
new uncommitted fold. It does not cover the case where the target path is already dirty and the
correct routing (stated elsewhere in the skill: extend the existing fold under its single
version bump rather than opening a competing one) means folding adds no new entanglement — the
tree is equally dirty either way, and deferring would instead risk a second, competing fold
later.

**Suggested fix:** Qualify the deferral so it turns on marginal entanglement, not on the gate
state alone: with the commit gate blocked, defer a MUST-FOLD item that would newly dirty a
clean path, but extend an existing uncommitted fold on the same path under its single version
bump. Either way, do not rename the source learning to `.learned.md` — the rename must follow
the commit, so an applied-but-uncommitted fold leaves the learning unrenamed and the state gets
reported as "distilled, not landed."
