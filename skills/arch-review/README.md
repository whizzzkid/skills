# wk-arch-review

Expert-level critical review of software architecture documents, specs,
implementation plans, and delivery estimates. Surfaces SPOFs, unhappy paths,
and underlying assumptions. Can also author architecture documents and generate
interactive HTML playgrounds that visualise a proposed design and its failure
modes.

## Trigger

- Reviewing an architecture doc, RFC, spec, or ADR
- Authoring a new architecture document or implementation plan
- Reviewing a delivery estimate for feasibility and risk
- Wanting a visual, interactive summary of a proposed architecture
- Phrases: "review this arch", "review this spec", "critique this design",
  "what are the failure modes", "write an arch doc for",
  "architecture playground"

## Key Phases

```mermaid
flowchart TD
    A([User invokes]) --> B[Step 1: Resolve input\nREVIEW or WRITE mode]
    B --> C[Step 2: Gather context\nscale, constraints, quality attrs]
    C --> D[Step 3: Critical analysis\n8 lenses A–H]
    D --> E[Step 4: Findings report\nSPOF map, assumptions table,\nprioritised actions]
    E --> F{Playground\nrequested?}
    F -->|yes| G[Step 5: Interactive HTML\nfailure-injection diagram]
    F -->|no| H([Done])
    G --> H
```

## Analysis Lenses

Eight lenses applied in Step 3 — each must be addressed even if the
finding is "none observed":

| Lens | Focus |
|------|-------|
| A — SPOF | Components whose failure cascades beyond expected blast radius |
| B — Unhappy paths | Timeouts, queue overflow, split deploys, migration failures |
| C — Assumptions | Explicit, implicit, verified vs. unverified |
| D — Scalability | Bottlenecks at 10×/100× load, hot partitions, O(n²) |
| E — Security | Trust boundaries, data exposure, SSRF/injection risk |
| F — Operability | Observability, graceful degradation, rollback |
| G — Cost | Over-provisioning, cross-region transfer, no cost ceiling |
| H — Delivery risk | External dependencies, unproven tech, missing milestones |

## Output Shape

- **Findings report:** severity-rated (🔴🟠🟡🟢), each with problem, failure
  mode, concrete recommendation, and effort estimate.
- **SPOF map:** every single point of failure with its blast radius.
- **Assumptions table:** each assumption with verified/unverified/risky status.
- **Prioritised actions:** ordered by risk-reduction × effort.
- **Playground (optional):** self-contained HTML with interactive failure
  injection and gotcha callouts.

## Model

`opus` — deep reasoning required; adversarial by design.

## Noteworthy

- Step 3 output is findings only — no paraphrasing or praise padding
  (except a short "What the Design Gets Right" section for credibility).
- Playground is generated inline; no external dependency.
- "Out of scope" sections in the input doc are explicitly reviewed —
  they often contain the riskiest deferred decisions.
- Related: [`wk-pr-review`](../pr-review/README.md) (code-level review),
  [`wk-adversarial-review`](../adversarial-review/README.md) (pre-push
  adversarial check).

## Status

⚠️ **RED phase not yet run.** Step bodies are DESIGN NOTES only — scaffold
awaiting baseline testing before GREEN implementation.
