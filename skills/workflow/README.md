# wk-workflow

> Master workflow for all development tasks — orchestrates every wk-* skill in prescribed order.

**Version:** `2026.07.30-220754`

## Invocation

| Mode | Trigger |
|------|---------|
| User-invocable | not directly invocable |
| Model-invocable | automatic: fires on every task that will produce code changes, a commit, or a PR |

## How It Works

```mermaid
flowchart TD
    A[Phase 1: wk-plan] --> B[Phase 2: Implement]
    B --> B1[Each step: tests → wk-workstyle → wk-docs → wk-commit]
    B1 --> C[Phase 3: Test — happy + sad + edge]
    C --> C1[Phase 3.5: refactor/reuse scan]
    C1 --> C2[Phase 3.6: frontend live preview when UI changes]
    C2 --> G[Phase 5: wk-pr — draft first, then mark ready]
    G --> D[Phase 5.5: wk-adversarial-review]
    G -.->|CI runs concurrently| H
    D --> E{Verdict}
    E -->|blocked| F[Fix blockers via wk-commit → re-invoke]
    F --> D
    E -->|clear| H[Phase 6: CI Fix Loop — max 3 attempts]
    H --> I{CI green?}
    I -->|no — 3 attempts| J[Stop + ask user]
    I -->|yes| K[Phase 6.5: resolve review comments]
    K --> L[Phase 7: wk-docs final audit]
    L --> M[Phase 8: wk-retro — NON-NEGOTIABLE]
    click A href "https://github.com/whizzzkid/skills/blob/main/skills/plan/README.md" _blank
    click D href "https://github.com/whizzzkid/skills/blob/main/skills/adversarial-review/README.md" _blank
    click G href "https://github.com/whizzzkid/skills/blob/main/skills/pr/README.md" _blank
    click K href "https://github.com/whizzzkid/skills/blob/main/skills/pr-resolve/README.md" _blank
    click L href "https://github.com/whizzzkid/skills/blob/main/skills/docs/README.md" _blank
    click M href "https://github.com/whizzzkid/skills/blob/main/skills/retro/README.md" _blank
```

## Noteworthy

- **Live learning capture is a Mandatory Activation rule** — invoke
  [`wk-learn`](../learn/README.md) before ending a response that handles a correction or
  self-caught error, and after every skill run. Phase 8 only audits that capture.
- **No opt-out, no size exemption** — "this is small" and "just a quick fix" are explicitly
  named red flags. If a diff will be produced, the full workflow applies.
- **Skill invocation is mandatory** via the `Skill` tool — approximating skill behavior with
  raw commands skips guards and conventions that the skills contain.
- **Progressive disclosure:** the skill is debloated under 500 lines. Phase 1 delegates to
  [`wk-plan`](../plan/README.md), and later phases invoke focused skills instead of inlining their full
  rule sets.
- **Phase 1 delegates to [`wk-plan`](../plan/README.md)** — all planning gates and probes live there:
  Jira pre-flight, user-provided artifact first, prefactor probe, intra-file duplication probe,
  spec pre-flight, new-capability probe, rule-set doc sync probe, tool-swap flag-parity probe,
  and producer-audit probe. A plan the user supplies — or one produced earlier this session —
  is never re-planned: it is validated for stale references, then executed from Phase 2.
- **Artifact sync with code changes** — a commit changing logical structure must update spec,
  plan, inline comments, test names, and any ADR in the same commit (mechanics in
  [`references/doc-sync-mechanics.md`](references/doc-sync-mechanics.md)). No deferred rewrites.
- **One review gate, anchored to merge — Phase 5.5 is its only dispatch point.**
  [`wk-adversarial-review`](../adversarial-review/README.md) runs after publish
  and ready, so CI runs concurrently. Clearance follows reviewed work:
  finding-response commits and tree-identical rewrites preserve it; unmatched
  scope, refactor, or logic gets one delta-scoped review.
- **CI fix loop** has a 3-attempt limit with an axis-of-variation check: attempts 1 and 2 on
  the same axis require broadening to a different axis on attempt 3, not "the same thing harder."
- **Phase 8 ([`wk-retro`](../retro/README.md)) is non-negotiable** — mandatory regardless of task outcome, even if
  the session was short or nothing interesting happened.
