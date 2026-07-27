---
skill: wk-sharpen
date: 2026-07-27
type: gap
severity: medium
verified-against-source: yes
---

A fold that edits the gate governing its own landing must satisfy the stricter of the old
and new rule, not the one it is writing.

**What happened:** The fold's subject was the byte-budget gate itself — it rewrote the rule
deciding whether a content-adding edit may land. That rule then arbitrated the fold's own
+43 B addition. Under the pre-edit text (net non-positive, unconditional) the fold could not
land; under the post-edit text (reclaim owed only once the headroom trigger fires, and
headroom was 167 B against a 43 B edit, so the trigger stayed silent) it could land with no
reclaim at all. Nothing in the skill said which text governs the run performing the edit, so
the run could have authorized its own edit by writing the authorization.

The run resolved it conservatively — hunted reclaim anyway and landed net −40 B, satisfying
both readings — but that was judgement, not instruction, and the next run has nothing to
reach for.

**Root cause:** The skill treats the fold and the rules governing the fold as independent,
which holds for every fold *except* one whose target is a Step 5 / Step 7.5 gate. There the
edit and the gate are the same text, and "apply the skill as written" becomes ambiguous
between the version read at Step 2 and the version drafted at Step 4. Verified by reading
the full `SKILL.md` and the byte-budget reference: no rule addresses the self-governing
case, and the general instruction to bump and re-read after editing does not reach it,
because the ambiguity bites *before* the edit lands.

A self-governing fold is also the case where a permissive edit is most attractive and least
checkable — the loosened rule's first beneficiary is the run that loosened it, and the
resulting commit looks fully compliant under its own new text.

**Suggested fix:** Add a rule to the fold-drafting step: when the edit target is a gate,
threshold, or budget rule that governs this run's own edit, evaluate the run against the
**stricter** of the pre-edit and post-edit text; the new rule takes effect from the next
run, once installed. Note the parallel to the existing escalation rule that already refuses
to credit worktree-only text ("a rule strengthened only in an uncommitted worktree fold
never steered the failing run") — the same installed-vs-worktree distinction resolves this,
applied in the permissive direction rather than the punitive one. Record the self-governing
determination and which text was applied in the run report, so the conservative choice is
visible rather than implicit.
