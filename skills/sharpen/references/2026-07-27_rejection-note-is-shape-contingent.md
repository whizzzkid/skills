---
class: principle
---

# A rejection note is a verdict under an edit shape, not a fact about the target

**Rule** — A recorded stay-inline / rejected-relocation / pool-exhaustion note suppresses a
reclaim candidate **only while the grounds it states still hold**. Grounds unstated,
aggregate, or scored before a shape now in reach → re-test under a cut-site pointer, never
veto. Write every new note so it names the edit shape it was scored under, and score
candidates individually.

**Why** — The grep rule told a run to honour recorded notes but never said a verdict can
expire. A rejection is scored against the edit shapes available *at the time*; widen those
shapes and the verdict goes stale, yet the note reads identically before and after. Read as
a fact about the target, every historical rejection hardens into a permanent veto, and the
reclaim pool shrinks monotonically for reasons no longer true.

**Verified against source** — Confirmed before drafting, not taken from the report:

- The two bullets sit adjacent in reading order (grep first, re-test second), so the
  report's "the reader never reaches the re-test rule" framing is a *reachability* claim the
  source disproves. The reproduction sharpened it: the defect is the re-test bullet's
  **antecedent narrowness** — it fires only for a target "rejected purely on reading order".
- Three independent records carry the same grounds-free aggregate verdict — "every remaining
  candidate carries a recorded stay-inline or rejected-relocation note". None scores an
  individual target, so the narrow re-test bullet can never fire against them and nothing
  else reopens them. That is the mechanism, and it is why two prior passes walked past a
  live pool.
- One of those three had an amendment appended recording the mis-test, but nothing in
  `SKILL.md` routes a reader from a grep hit to an amendment — confirming the note itself,
  not the reader's path, must carry its own expiry conditions.

**Scope limit** — Grounds naming a property the ceiling never outranks (a gate's enumerated
pass/fail checks, a verification checklist, a verified-configuration qualifier) hold under
every shape. Those vetoes are permanent by design and this rule must not be read as
reopening them.

**Classification** — `principle`. Generalizes to any durable-record-plus-gate pairing where a
recorded verdict is consulted by a later pass that cannot see the conditions it was scored
under.

**Self-governance** — This fold edits the very gate governing its own reclaim hunt. Per the
stricter-of-pre-and-post rule, the **pre-edit** text was applied throughout: every recorded
note was treated as a hard veto for this run. Reclaim categories 1 and 3 were therefore
closed, and the fold landed on target 5 (tighten the addition) alone. The loosened reading
takes effect next run, once installed.

**Rejected reclaim target (do not re-propose)** — The reclaim-order bullet "Never reclaim a
rule's earliest statement", scored as a duplicate of the de-bloat merge bullet that states
the same protection earlier. Its own record shows it was *authored* as the deliberate
forward cross-reference (+129 B, "placement obeys the rule it adds"). Grounds are stated and
still hold under every available shape, so the veto survives both the pre-edit and the
post-edit test — a worked example of the distinction this fold adds.

**Where** — `SKILL.md` → Step 7.5, size-ceiling reclaim search: the grep bullet gains the
"only while its stated grounds still hold" qualifier, and the narrow reading-order re-test
bullet is generalized to the three invalidating patterns, subsuming reading order as one
named instance. Full failure-mode catalog and the note-authoring requirement →
[`byte-budget.md`](byte-budget.md) "A rejection note is a verdict under an edit shape".

**Escalation** — None. Not a re-violation: the re-test rule landed the same day and this is
the first pass to exercise it against a non-reading-order note. Per the repeat-traces-to-
shape rule, the framing fix is the load-bearing part.

**Arithmetic for this fold** — Old span 295 B → new span 350 B, net **+55 B**; body
24411 → 24466 B against a 24576 B ceiling, 110 B remaining. Measured audit-cleanup inside
the ceiling-bound file **0 B** — the Step 5 audit ran before the budget locked, and both
cleanup items (amending the two stale aggregate notes) land outside the ceiling. The
headroom trigger stayed silent: 165 B headroom ≥ 2× the 55 B edit, so net-non-positive was
not owed and no reclaim was hunted. Only a ceiling blocks.
