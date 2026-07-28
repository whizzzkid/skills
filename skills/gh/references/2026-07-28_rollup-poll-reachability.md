---
class: principle
---

# A rollup rule sited under `--watch` never reaches a hand-rolled poll

**Rule** — the `statusCheckRollup` union rules govern **every** consumer: the watch
subcommand, a hand-rolled `until` loop, and a one-shot readiness check. Site them in
their own section reached before any of those, never nested under one consumer's
heading. Report with coalescing fallbacks (`.name // .context`, `.conclusion // .state`);
an entry projecting all-null through check-run field names is a status context read
through the wrong shape, not an empty gate.

**Why** — the correct union rule was already installed, but lived under the
`gh pr checks --watch` heading. An agent writing its own poll never reached that
section, wrote `select(.status != null)`, and the loop exited immediately on three
SUCCESS check-runs while the build — a status context with both `.status` and
`.conclusion` null — was still `PENDING`. The repeat traced to the rule's placement,
not its wording, so relocation is the load-bearing fix and the one-rung escalation
only records it.

**Escalation** — baseline prose → `**Important:**` (rung 1 → 2), one notch, recorded
here and in [`2026-07-22_ci-rollup-status-and-state.md`](2026-07-22_ci-rollup-status-and-state.md).

**Where** — `skills/gh/SKILL.md` → *Reading `statusCheckRollup`*; over-general
check-run-only projection corrected in `skills/pr/SKILL.md` CI-green gate.
