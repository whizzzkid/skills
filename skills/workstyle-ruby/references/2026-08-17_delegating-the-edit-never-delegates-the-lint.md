---
class: principle
---

# Delegating the edit never delegates the lint

**Rule** — Whoever stages runs the linter, however the code was produced: an agent
that cannot run shell, a coordinator applying another agent's edits, or a patch
taken from elsewhere. Unowned lint is unrun lint.

**Why** — The pre-stage lint rule (installed 2026-06-26) and the ASCII-only-comment
rule (2026-06-01) were both live and both violated: parallel agents wrote em dashes
into comments and `Style/AsciiComments` caught them in CI. The rule said *when* to
lint but presumed a single actor who both edits and stages. Split those roles across
a coordinator and isolated agents and the obligation lands on nobody — each actor can
truthfully say linting was not theirs. Non-ASCII comment characters are the
signature failure here precisely because only the linter sees them, so a
handoff-shaped gap surfaces them and nothing else does.

**Where** — `skills/workstyle-ruby/SKILL.md` → the pre-stage rubocop rule, escalated
and given the ownership sub-bullet.

## Escalation record

- Re-violation of a rule live since 2026-06-26 → escalated one rung: **1 (baseline
  prose) → 2 (`**Important:**`)**.
- Escalated the *rubocop-before-staging* rule rather than the ASCII-comment rule:
  running the linter would have caught the em dashes, so the unrun linter is the
  proximate failure and the ASCII cop is what it would have reported.
- No positive-steering evidence blocked it — that session's "What worked" bullets
  covered the coordinator pattern, research-first planning, and parallel dispatch.
- The workflow skill's "coordinator runs shell ops after agents complete edits" rule
  is the sibling coverage, but it landed 2026-08-13 at 19:23Z against a retrospect
  written 18:54Z the same day — **already-covered (unshipped)**, so no notch there.

## Rejected: skipping the adversarial-review gate for "simple" diffs

The same source asked the workflow skill to recognize low-complexity diffs
(CSS/routing fixes) and skip the full adversarial-review gate unless explicitly
requested. **Rejected — this relaxes a guard.** An agent-side complexity heuristic
is exactly the judgment the gate exists to not depend on, and "simple diff" is
self-assessed by the party whose work is under review.

The legitimate half is already covered: the user's "just mark ready" is a **waiver**,
and *waiver is final* has been installed since 2026-07-28, with a 2026-07-30
distillation putting user opt-outs ahead of any tool-presence probe. Authority to
skip comes from the user, never from the diff's apparent size. Do not re-propose the
heuristic; if gate cost is the real concern, surface the cost and let the user waive.
