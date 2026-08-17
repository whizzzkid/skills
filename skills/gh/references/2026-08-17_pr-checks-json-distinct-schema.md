---
class: principle
---

# `gh pr checks --json` and `statusCheckRollup` are different schemas

**Rule** — Probe a subcommand's own `--json` field set before projecting from it.
`gh pr checks --json` exposes `bucket, completedAt, description, event, link,
name, startedAt, state, workflow` — no `.status` and no `.conclusion` — so the
heterogeneous-union predicate written for `statusCheckRollup` does not transfer.
Prefer `bucket` (`pass|fail|pending|skipping|cancel`) over hand-classifying
`state`; exit code `8` means checks pending.

**Why** — The skill documented the rollup union rules thoroughly, and a run
reading CI through the *other* command inherited none of them. Field names that
are simply absent read as null, which the skill already warns is "a status
context read through the wrong shape" — but that warning was scoped to the
rollup, so nothing flagged the cross-command case. Verified against
`gh pr checks --help`, not inferred.

**Where** — `skills/gh/SKILL.md` → new section immediately before *A required
context can be absent without failing*, so the `--required` caveat sits next to
the `required - observed` computation it must not replace.

## Why `--required` is not the missing-context answer

`--required` filters to policy-required checks **that posted**. A required
context that never ran is absent from that list exactly as it is absent from the
rollup, so the explicit `required - observed` computation against the active
ruleset remains the only way to see it. Recording this so a later pass does not
"simplify" the missing-context section into a `--required` call.

## Classification

- `partial`, not a re-violation: the installed union rule and the required-context
  section both predate the report, but both are scoped to surfaces the failing run
  did not use. No escalation notch — the failing shape was unenumerated, and
  escalating a rule that never covered the case would burn ladder headroom on the
  wrong rule.
