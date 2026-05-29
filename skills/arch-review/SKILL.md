---
name: wk-arch-review
description: >-
  Use when reviewing or authoring software architecture documents, specs,
  implementation plans, or delivery estimates — performs expert-level critical
  evaluation of system design, surfaces SPOFs, unhappy paths, and underlying
  assumptions, and can generate an interactive HTML playground to visualise the
  architecture and its gotchas.
argument-hint: '[<doc-path-or-url> | write <topic>]'
allowed-tools:
  - Bash
  - Read
  - Glob
  - Grep
  - Write
  - Edit
  - Skill
  - WebFetch
  - AskUserQuestion
  - "mcp__plugin_playwright_playwright__*"
model: opus
effort: high
model-invocable: true
user-invocable: true
license: MIT
group: workflows
metadata:
  author: whizzzkid
  version: '2026.05.29-065051'
  internal: false
  model:
    claude: claude-opus-4-8
    openai: o3
    google: gemini-2.5-pro
---

# Architecture Review

<!-- RED phase not yet run — fill in after testing baseline behavior -->

Expert-level critical review of software architecture documents, specs,
implementation plans, and delivery estimates. Surfaces design weaknesses
and produces a structured, actionable findings report. Can also author
architecture documents from scratch, and generate interactive HTML
playgrounds that visualise a proposed design and its failure modes.

## When to Use

- Reviewing an existing architecture doc, RFC, spec, or ADR
- Authoring a new architecture document or implementation plan
- Requesting a delivery estimate review for feasibility and risk
- Wanting a visual, interactive summary of a proposed architecture
- Trigger phrases: "review this arch", "review this spec", "review this
  RFC", "critique this design", "what are the failure modes", "write an
  arch doc for", "architecture playground"

## Step 1: Resolve the Input

<!-- RED phase not yet run — fill in after testing baseline behavior -->

<!-- DESIGN NOTES:
  Two modes:
  (a) REVIEW — the user provides a path, URL, or pastes a document.
      Read it. If a URL, fetch it. If a directory, scan for *.md / *.txt /
      *.pdf design files. If nothing is provided, ask the user once.
  (b) WRITE — the user asks to author a new document (e.g., "write an arch
      doc for a payment processing service"). Proceed to Step 2 to gather
      context, then return here to scaffold the doc.

  Extract from the document (or user intent for WRITE mode):
  - System name and purpose
  - Components / services / layers described
  - Data flows and state management
  - Scalability and availability claims
  - Technology choices named
  - Anything described as "out of scope" or "future work"
  - Any explicit SLAs, SLOs, or performance budgets stated
-->

## Step 2: Gather Context

<!-- RED phase not yet run — fill in after testing baseline behavior -->

<!-- DESIGN NOTES:
  Ask (or infer from the document) before reviewing:
  1. What is the operational scale? (users, RPS, data volume, regions)
  2. What are the top-3 quality attributes? (availability, latency, cost,
     security, maintainability — rank them)
  3. What is the deployment environment? (cloud provider, on-prem, edge,
     hybrid)
  4. What are the hard constraints? (regulatory, budget, team size,
     technology mandates)
  5. What is the timeline / delivery target?

  If the document answers these, extract them directly — do not ask the
  user for information that is already in the text. Only ask for what is
  genuinely absent and material to the review.

  Record as a "Context Block" at the top of the review output.
-->

## Step 3: Critical Architecture Analysis

<!-- RED phase not yet run — fill in after testing baseline behavior -->

<!-- DESIGN NOTES:
  This is the core analysis step. Apply the following lenses exhaustively.
  Do not summarise or praise — surface problems and gaps only. Each finding
  must be: (1) specific, (2) actionable, (3) rated by severity.

  LENS A — Single Points of Failure (SPOF)
    - Every component / service / dependency that, if it fails, takes down
      a materially larger surface than expected.
    - Hidden SPOFs: databases without replicas, message queues without
      consumer redundancy, shared caches, CDN origin-pull chains, DNS,
      cron schedulers, monolithic auth services.
    - Ask: "What happens when this component is unavailable for 5 minutes?
      30 minutes? Permanently?"

  LENS B — Unhappy Paths
    - What happens when a downstream call times out?
    - What happens when a queue backs up beyond its retention window?
    - What happens when a deploy is partially rolled out (split-brain)?
    - What happens when a data migration fails mid-flight?
    - What happens when a third-party API changes its contract?
    - Are retry budgets and circuit breakers specified?
    - Is idempotency guaranteed for all mutating operations?

  LENS C — Underlying Assumptions
    - List every assumption the design makes that is not explicitly stated.
    - Examples: "assumes the network is reliable", "assumes the third-party
      SLA is met", "assumes the team can deliver feature X in 2 weeks",
      "assumes read:write ratio is 10:1".
    - Flag each as Verified (has evidence) / Unverified (needs validation) /
      Risky (plausible but high-impact if wrong).

  LENS D — Scalability and Performance
    - Where are the bottlenecks as load increases 10×? 100×?
    - Is there a hot-partition / hot-key risk in any storage layer?
    - Are there O(n) or O(n²) operations hiding in the design?
    - Are connection pool sizes and thread budgets stated?
    - Is there a thundering herd risk on cold start or cache eviction?

  LENS E — Security and Trust Boundaries
    - Where do trust boundaries cross (internal ↔ external, authn ↔ authz)?
    - Is sensitive data ever stored in logs, caches, or queues unencrypted?
    - Are there SSRF, injection, or confused-deputy risks at API boundaries?
    - Is the blast radius of a compromised service minimised?

  LENS F — Operability and Observability
    - Is there a clear on-call runbook surface implied by the design?
    - Are there enough metrics / traces / logs to diagnose each failure mode?
    - Is there a graceful degradation path, or is it all-or-nothing?
    - Can the system be deployed, rolled back, and re-deployed without
      downtime?

  LENS G — Cost and Resource Efficiency
    - Are there obvious over-provisioning traps (e.g., always-on compute
      for bursty workloads)?
    - Are data-transfer costs considered for cross-region / cross-AZ flows?
    - Is there a cost ceiling or alert strategy described?

  LENS H — Delivery Risk
    - Are there external dependencies (third parties, other teams, hardware)
      on the critical path?
    - Is the estimate broken into phases with independently verifiable
      milestones?
    - Are there unproven technology choices that add discovery risk?
    - What is the minimum viable slice that validates the riskiest assumption?
-->

## Step 4: Produce the Findings Report

<!-- RED phase not yet run — fill in after testing baseline behavior -->

<!-- DESIGN NOTES:
  Format the findings as a structured document:

  ## Architecture Review: <System Name>
  **Reviewer role:** Distinguished Engineer / Principal Architect
  **Date:** <YYYY-MM-DD>

  ### Context Block
  (filled from Step 2)

  ### Critical Findings
  Severity: 🔴 Critical | 🟠 High | 🟡 Medium | 🟢 Low | ℹ️ Info

  #### [SEVERITY] <Finding Title>
  **Lens:** <A–H>
  **Location in doc:** <section or line reference>
  **Problem:** One precise paragraph — what is wrong and why it matters.
  **Failure mode:** What breaks, when, and the customer-visible impact.
  **Recommendation:** Concrete, actionable. Name the specific pattern,
    technology, or design change. Not "consider X" — "do X because Y."
  **Effort to fix:** [Hours | Days | Weeks] with brief rationale.

  ### Underlying Assumptions Table
  | Assumption | Status | Risk if Wrong |
  |------------|--------|---------------|

  ### SPOF Map
  (text diagram or list — each SPOF with its blast radius)

  ### Recommended Prioritised Actions
  Ordered by: (1) risk reduction, (2) effort. Short-form bullets.

  ### What the Design Gets Right
  (One short section — honest acknowledgement of sound choices, to
  establish credibility and show the review is balanced, not just hostile.)

  No padding. No hedging. Findings must be falsifiable.
-->

## Step 5: Generate Interactive HTML Playground (optional)

<!-- RED phase not yet run — fill in after testing baseline behavior -->

<!-- DESIGN NOTES:
  If the user requests a playground (or the architecture is complex enough
  that a visual would materially help), generate a single self-contained
  HTML file that:

  - Renders the architecture as an interactive diagram (use mermaid.js or
    a canvas-based graph, self-hosted from a CDN or inlined as a data URI
    so the file works offline).
  - Has toggleable "failure injection" controls: click a component to
    mark it as failed and see which downstream components turn red.
  - Shows a sidebar with: the component's role, its dependencies, and the
    worst-case blast radius if it fails.
  - Lists the top-N findings from Step 4 as callout overlays on the
    relevant components.
  - Includes a "Gotcha" panel that cycles through the critical findings
    with a Next/Prev button.

  Write the file to the current directory as `arch-review-playground.html`
  (or a name derived from the system being reviewed). Open it in the
  default browser to verify it renders.

  The playground is a communication tool — prioritise clarity over
  completeness. One clear diagram beats a cluttered one.
-->

## Common Mistakes

<!-- These will be populated from field learnings after RED phase -->

- Summarising what the document says instead of critiquing it — the output
  must be findings, not a paraphrase.
- Using hedge language ("consider", "might want to", "could potentially") —
  findings must be direct imperatives backed by reasoning.
- Missing hidden SPOFs that are not explicitly named in the document (DNS,
  shared secrets stores, single deployment pipelines, etc.).
- Treating "out of scope" sections as non-reviewable — they are often where
  the riskiest deferred decisions live.
- Producing a findings list without a prioritised action plan.

## Quick Reference

| Invocation | Behavior |
|------------|----------|
| `/wk-arch-review path/to/doc.md` | Review a local architecture document |
| `/wk-arch-review https://...` | Review a doc at a URL |
| `/wk-arch-review write <topic>` | Author a new architecture document |
| `/wk-arch-review playground` | Generate interactive HTML playground for last reviewed doc |

## Requirements

- Read access to the document being reviewed (local path or URL)
- Write access to the current directory (for playground output)
- `wk-playground` is NOT required — playground output is generated inline by this skill

---

## Post-Completion

Invoke [`wk-learn`](../learn/README.md) with this skill's short name as the argument
(e.g., `wk-learn arch-review`).
