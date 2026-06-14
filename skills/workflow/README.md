# wk-workflow

> Master workflow for all development tasks — orchestrates every wk-* skill in prescribed order.

**Version:** `2026.06.14-090215`

## Invocation

| Mode | Trigger |
|------|---------|
| User-invocable | not directly invocable |
| Model-invocable | automatic: fires on every task that will produce code changes, a commit, or a PR |

## How It Works

```mermaid
flowchart TD
    A[Phase 1: wk-plan] --> A1[Grill ambiguities]
    A1 --> A2[Research gates + planning probes]
    A2 --> A3[Present numbered plan + wait for approval]
    A3 --> B[Phase 2: Implement]
    B --> B1[Each step: tests → wk-workstyle → wk-docs → wk-commit]
    B1 --> C[Phase 3: Test — happy + sad + edge]
    C --> D[Phase 4: wk-adversarial-review]
    D --> E{Verdict}
    E -->|blocked| F[Fix blockers via wk-commit → re-invoke]
    F --> D
    E -->|clear| G[Phase 5: wk-pr — always draft first]
    G --> H[Phase 6: CI Fix Loop — max 3 attempts]
    H --> I{CI green?}
    I -->|no — 3 attempts| J[Stop + ask user]
    I -->|yes| K[Phase 7: wk-docs final audit]
    K --> L[Phase 8: wk-retro — NON-NEGOTIABLE]
    click A href "../plan/README.md" _blank
    click D href "../adversarial-review/README.md" _blank
    click G href "../pr/README.md" _blank
    click K href "../docs/README.md" _blank
    click L href "../retro/README.md" _blank
```

## Noteworthy

- **No opt-out, no size exemption** — "this is small" and "just a quick fix" are explicitly
  named red flags. If a diff will be produced, the full workflow applies.
- **Skill invocation is mandatory** via the `Skill` tool — approximating skill behavior with
  raw commands skips guards and conventions that the skills contain.
- **Phase 1 delegates to [`wk-plan`](../plan/README.md)** — all planning gates and probes live there:
  Jira pre-flight, user-provided artifact first, prefactor probe, intra-file duplication probe,
  spec pre-flight, new-capability probe, rule-set doc sync probe, tool-swap flag-parity probe,
  and producer-audit probe.
- **Design pivots travel with their docs** — a commit changing logical structure must update
  spec, plan, inline comments, test names, and any ADR in the same commit. No deferred rewrites.
- **CI fix loop** has a 3-attempt limit with an axis-of-variation check: attempts 1 and 2 on
  the same axis require broadening to a different axis on attempt 3, not "the same thing harder."
- **Phase 8 ([`wk-retro`](../retro/README.md)) is non-negotiable** — mandatory regardless of task outcome, even if
  the session was short or nothing interesting happened.
