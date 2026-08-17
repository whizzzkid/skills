---
class: principle
---

# A standing repo mandate authorizes publication as fully as the prompt does

**Rule** — A mandated PR lifecycle authorizes the initial task-branch push and PR
creation. The mandate may be standing (a repo/agent-instruction requirement) as
much as spoken in the originating prompt; neither needs a confirmation round.
Ask only where publishing is genuinely optional.

**Why** — The authorization rule already existed, but every gate that fires at
push time enumerated only *the session's originating prompt* as the authorizing
source. An agent reading that enumeration treats a standing repo mandate as
unenumerated, confirms anyway, and stalls a lifecycle the repo already requires.
The rule's shape, not its presence, produced the repeat.

**Where** — `skills/workflow/SKILL.md` → the act-without-asking rule, escalated
one rung to `**Important:**`; `skills/commit/SKILL.md` → the first-push exception
clause, widened to name a repo mandate alongside the originating prompt.

## Escalation record

- Re-violation of a rule installed before the report → escalated exactly one rung
  on the 8-rung ladder: **rung 1 (baseline prose) → rung 2 (`**Important:**`)**.
- No positive-steering evidence blocked the escalation: the session's "What
  worked" bullets covered post-push verification, not this gate.
- The notch records the repeat; the load-bearing fix is the cross-skill framing
  sync, since the gate that actually fires lives in the commit skill while the
  rule lived only in the workflow skill. Enumerating authorization sources in one
  skill and gating on them in another is the drift shape to watch for.

## Second lesson from the same source: head identity at the completion gate

**Rule** — "CI green" counts only against the current head: local HEAD, remote
head, and the SHA the checks ran against must be one commit before completion is
claimed.

**Why** — The source asserted this as a practice that *worked*, so no escalation
applies. It was nonetheless absent from the completion checklist, which gated on
"CI fix loop exited green" without binding that green to the head being shipped —
a stale green passes the gate. The existing remote-head verification lived only
inside the stacked-PR recovery rule, scoped to recovery rather than completion.

**Where** — `skills/workflow/SKILL.md` → Checklist, folded into the CI-green line
rather than added as a separate box, so the green and the head it refers to cannot
be checked independently.

