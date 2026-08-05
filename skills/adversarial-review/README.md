# wk-adversarial-review

> Adversarial review of the current branch before it merges — **exactly one run per change**, at the completion gate (plan executed, PR published and ready). Every other skill reads the recorded verdict instead of dispatching.

**Version:** `2026.08.05-193323`

## Invocation

| Mode | Trigger |
|------|---------|
| User-invocable | `/wk-adversarial-review [base-branch]` |
| Model-invocable | completion gate only; readers never dispatch |

## How It Works

```mermaid
flowchart TD
    A[Resolve base branch] --> B[Build diff surface map]
    B --> C[Run 101 mechanical sweeps]
    C --> D[Spawn fresh adversarial subagent]
    D --> E[Playground validation]
    E --> F{Verdict}
    F -->|Clear| G[Write .cleared-SHA.json<br/>Hand back to caller]
    F -->|Blockers| H[Print blocker list<br/>Refuse to proceed]
    F -->|Suggestions only| I[AskUser: fix/clear/defer]
    H --> J[Caller fixes → re-invoke]
    J --> K{Only recorded finding responses?}
    K -->|yes| V[Validate recorded fixes only]
    V --> F
    K -->|new work| C
    I --> G
```

## Noteworthy

- **No opt-out exists.** "Small fix", "trivial", and "docs-only" are explicitly named red flags, not exemptions — even a docs commit can contradict test counts in a spec.
- **Clearance follows reviewed work, not SHA equality** — tree-identical rewrites
  preserve the record. Finding-response commits get targeted validation; only
  unmatched scope, refactor, or logic triggers a delta-scoped review.
- **101 mechanical sweeps run unconditionally** before LLM reasoning.
  Lower-frequency shape-specific sweeps live in
  `references/sweep-catalog-extended.md` under the same rule. The catalog covers
  security, sibling parity, guard correctness, docs/spec sync, contract
  widening, pipeline forwarding, cross-language stamped-binary contracts,
  LLM field preservation, log parsing, gate exit-status contracts,
  runtime portability, canonical numeric-text parsing, and test quality —
  including stable identities shared across typed sources and static fixtures,
  deterministic browser-profile parity across sibling harnesses, and bounded
  port-handoff recovery. Signature changes also trigger whole-repo stub and
  harness sweeps, with one real consumer driven per distinct harness.
- **One dispatch per change** — the completion gate owns the run;
  [`wk-pr-resolve`](../pr-resolve/README.md),
  [`wk-pr-review`](../pr-review/README.md),
  [`wk-pr-takeover`](../pr-takeover/README.md), and readers consume records.
  Fix rounds validate recorded findings without re-running sweeps or a subagent.
- **[`wk-pr-merge`](../pr-merge/README.md) is record-only** — missing clearance
  or genuinely new work returns to the completion gate; merge never dispatches.
- **Fresh adversarial subagent** — the diff is piped directly, never hand-transcribed; the subagent stays coverage-aware, refactor-aware, relocation-aware, and introduction-claim-aware.
- **Playground validation is mandatory** for any runtime-behavior claim — findings that cannot be reproduced in `.review-playground/` are downgraded from `blocker` to `question`. Every local run is scoped to the changed examples (never a suite or whole spec directory) — CI owns full-suite regressions, and mutation cycles inherit that scoping. The playground step owns the runtime matrix, mutation testing, the standalone upstream-source harness, specialized producer/consumer / cluster / interface-contract / allowlist checks, and read-based analysis for doc/prose/compression diffs (gate-survival-by-substance, count cross-checks, relocation portability).
- **Consumed as the investigation engine by [`wk-pr-review`](../pr-review/README.md)** — it delegates Phase 3 here and maps the returned findings into PR comments.
- **Targeted fix validation caps at 3 cycles.** After 3 blocked rounds, surface
  to the user; recurrence means diagnosis or design is wrong.
- **This skill is a gate, not an actor.** It never pushes, never posts PR comments, never edits the PR — those actions belong to the calling skill ([`wk-pr`](../pr/README.md), [`wk-workflow`](../workflow/README.md), [`wk-pr-resolve`](../pr-resolve/README.md)).
