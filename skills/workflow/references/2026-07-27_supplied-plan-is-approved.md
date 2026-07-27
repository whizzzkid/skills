---
class: principle
skill: wk-workflow
date: 2026-07-27
severity: medium
---

# A plan that already exists is validated, not re-planned — and supplying it is the approval

**Rule** — Phase 1 re-plans only when no plan exists. When the user supplies a plan (file,
doc, or prose), or `wk-plan` produced one earlier in the session, the phase collapses to a
bounded validation pass — references resolve, order still valid, nothing already done — with
stale references fixed in place, then execution starts at Phase 2.

**Second half, easy to miss** — the Phase 1 approval HARD RULE ("present-plan →
wait-for-approval → execute") would otherwise strand a supplied plan: the agent has nothing
to present and no approval to wait for, so it either re-presents the user's own plan back to
them or blocks. The rule now states that a supplied plan arrives approved.

**Why the prior wording was insufficient** — the existing bullet covered only "`wk-plan`
already produced an approved plan **this session**". A plan handed over at the top of a
session, or carried across a session boundary in a doc, matched neither clause, so the
HARD RULE at the head of the phase ("invoke `wk-plan` before any planning") took over and
paid full planning cost for work already planned.

**Failure mode prevented** — burning a planning cycle re-deriving an artifact the user
already wrote, then presenting it back for approval they already gave by handing it over.

**Byte budget** — addition +190 B across two sites (Phase 1 bullet, approval HARD RULE
tail); reclaim −53 B by deleting "Do not re-plan inline after an approved plan exists",
whose content the rewritten bullet now states in its own first clause and which sat later in
reading order. Net **+147 B**, body 24174 → 24321 of 24576 (255 B headroom). The edit is
under half the pre-edit headroom, so the ≥2-target / ≥1.2× reclaim budgeting rule does not
trigger.

**Deliberately not done** — the validation pass is left unenumerated beyond its three
checks. A per-artifact checklist (path exists, symbol exists, step already landed) belongs in
`wk-plan`, which owns plan structure; duplicating it here would put the same gate in two
skills and drift.
