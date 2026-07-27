---
class: principle
---

# Reclaim may delete only the later duplicate, never a rule's earliest statement

**Rule** — When two statements of one rule exist, de-bloat may delete only the occurrence a
run reaches *second*. The earliest statement is the one that actually guards; removing it
moves the rule later in reading order. Any de-bloat merge keeps the first occurrence and
cross-references *forward*, never backward.

**Why** — The reclaim rules protected content by **kind** (gate pass/fail checks,
verification checklists, load-bearing commands) and by **destination** (never behind a
pointer). Nothing protected content by **position**. A duplicate-detection pass is
order-blind: it scores two statements of one rule as redundancy with nothing scoring which
occurrence a run reaches first. For a reachability fold — one whose entire purpose is
moving a control rule *earlier* — ceiling pressure and the fold's intent point in exactly
opposite directions, so the byte hunt argues persuasively for undoing the fix. The
duplicated upstream statement scores as the most attractive target available: provably
duplicated, not a gate's enumerated checks, not a relocation, so no recorded prohibition
fires.

**Verified against source** — Confirmed before drafting, not taken from the report:

- Grepped the positional vocabulary (`earliest`, `reading order`, `reached first`,
  `forward, not backward`) across the skill body and its references. The only hit was a
  per-learning distillation record — never linked from `SKILL.md`, therefore absent at
  runtime. The body carried no positional constraint at all.
- Re-read the reclaim rules directly: the structural-moves bullet, the ordered duplicate
  search, and the gate/checklist protection all key on kind or destination. Confirmed
  order-blind.

**Classification** — `principle`. Generalizes past the byte budget to any merge of
duplicated rules.

**Escalation** — None. No existing rule failed; this is a genuine gap. The reporting run
rejected the bad reclaim only by *noticing* the ordering, not by applying a rule — absence
of guidance, not a re-violation of it.

**Placement obeys the rule it adds** — Stated in full at the de-bloat merge bullet, which
is the earliest point prescribing "state a rule once; cross-reference instead of
restating"; the reclaim search order, read later, carries a short cross-reference forward
to it.

**Rejected reclaim targets (do not re-propose)** — Two candidates failed their coverage
proof and were dropped rather than cut:

- The classification gate's "ask once" escape hatch. Its linked reference does state it,
  but it is a gate's escape path, which the ceiling never outranks.
- The structural-moves bullet's "zero coverage risk" rationale. Grepping the linked
  reference returned no match, so the inline text is the only statement — deleting it
  would have silently dropped content on an unproven assumption of duplication.

**Arithmetic for this fold** — Addition +315 B (de-bloat merge rule +186 B as a replacement
net; reclaim-order cross-reference +129 B). Reclaim −17 B, tightening a rationale clause
duplicated by its linked reference. Net **+298 B**; body 23253 → 23551 B against the 24576 B
ceiling, leaving 1025 B. The up-front reclaim-budgeting regime did not trigger: it fires
when headroom falls under ~2× fold-plus-allowance (1230 B) and headroom measured 1323 B. The
hunt stopped after the one proven target rather than widening into load-bearing content.

**Where** — `SKILL.md` → Step 7.5 de-bloat HARD RULE (positional constraint stated) and the
size-ceiling reclaim search order (cross-reference forward).

**Amended 2026-07-27 — the rule is about the pointer, not the content.** The
reading-order objection holds for a *deletion* (the surviving statement is elsewhere and
later). A *relocation* is exempt whenever the surviving pointer is written into the bullet
the block was cut from: the rule stays reachable at exactly the position it occupied.
Reserve the protection for content that cannot be pointed at from its own position — a
gate's enumerated pass/fail checks, a verification checklist. See
[`2026-07-27_pointer-at-cut-site.md`](2026-07-27_pointer-at-cut-site.md).
