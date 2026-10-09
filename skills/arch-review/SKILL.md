---
name: wk-arch-review
description: >-
  Use when reviewing or authoring software architecture documents, specs,
  implementation plans, or delivery estimates — performs expert-level critical
  evaluation of system design, surfaces SPOFs, unhappy paths, and underlying
  assumptions, and can generate an interactive HTML playground to visualise the
  architecture and its gotchas.
argument-hint: '[<doc-path-or-url> | write <topic> | playground]'
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
  version: "2026.10.09-171327"
  internal: false
  model:
    claude: claude-opus-4-7
    openai: gpt-5.6-sol
    google: gemini-2.5-pro
---

# Architecture Review

Distinguished-engineer-level critique of architecture docs, specs, plans,
estimates. Produces falsifiable findings — SPOFs, unhappy paths, hidden
assumptions, scaling cliffs — plus optional interactive HTML playground.

## Operating Stance

- Critique, don't summarise — output findings, not paraphrase.
- Every finding: failure mode + when it fires + customer impact. No "consider X."
- Severity-rate everything: 🔴 Critical · 🟠 High · 🟡 Medium · 🟢 Low · ℹ️ Info.
- Quantify when possible. One section acknowledges sound choices; the rest is problems.

## Non-Negotiable Contract

1. **Mandatory trigger** on any arch-bearing artifact (spec, ADR, RFC, design doc,
   HLD/LLD, plan, topology change, trust boundary, public API, migration).
   Authoring counts. Detect: `git diff --name-only "$BASE...HEAD" | grep -qiE
   'docs/(specs?|adr|arch|design|rfc|plans?)/|architecture|design|spec|rfc|adr'`.
2. **One dispatch per artifact version.** Record at `.review-playground/.arch-cleared-{SHA}.json`;
   all other callers read the record.
3. **Re-review only on change.** Unchanged → print record. Changed → one delta-scoped re-review.
4. **Only this skill satisfies the gate** — general subagents skip the Eight Lenses.

## Step 1: Resolve the Input

- **REVIEW** (default): local file → `Read`; URL → `WebFetch`; directory → scan for
  `arch|design|spec|rfc|adr|plan|hld|lld` files; nothing → ask once.
- **WRITE**: argument starts with `write` → skip to Step 2, author in Step 4's shape.
- **PLAYGROUND**: reuse last review's findings, jump to Step 5.

Extract: system name, components, data flows, consistency model, tech choices,
SLAs/SLOs, "out of scope" items (review those anyway).

## Step 2: Gather Context

Extract from doc first; ask only for genuinely absent material:
scale (RPS, data volume, regions), top-3 quality attributes, deployment env,
hard constraints (regulatory, budget, team), timeline.

Record as **Context Block** — every finding evaluated relative to this.

## Step 3: Critical Analysis — the Eight Lenses

Apply every lens; record findings or "none observed — reason." Full probe list:
`references/review-lenses.md`.

- **A · SPOFs** — hidden: primary-only datastores, single queues, shared caches, DNS, schedulers, one-region control plane. "Down 5/30 min? Permanently?"
- **B · Unhappy Paths** — timeouts, queue retention, split-brain, migration failure, duplicate delivery. Demand: retry budgets, circuit breakers, idempotency, dead-letter.
- **C · Assumptions** — enumerate unstated ones; tag Verified/Unverified/Risky. Cross-check settled vs. pending values. Self-referential assertions prove nothing.
- **D · Scalability** — bottleneck at 10×/100×; hot partitions; O(n²) in loops; connection pools; thundering herd; write amplification.
- **E · Security** — trust boundary crossings; secrets/PII in logs/caches/URLs; SSRF/injection/IDOR; blast radius per compromised service.
- **F · Operability** — metrics/traces/logs per failure mode; graceful degradation; zero-downtime deploy/rollback; kill switches.
- **G · Cost** — always-on compute for bursty load; cross-AZ transfer; per-request cost at scale; cost ceiling + alerting.
- **H · Delivery Risk** — critical-path external deps; unproven tech; phased milestones; minimum viable slice for riskiest assumption.

### Empirical pass

**HARD RULE:** Lens findings on executable logic are hypotheses, not conclusions.
When the doc describes executable logic (matcher, grader, parser, state machine), drive the real implementation with adversarial inputs and record
PASS/FAIL before returning. Mark untested findings **Unverified**.

## Step 4: Produce the Output

### Document-quality gate

Enforce before writing. See `references/2026-06-02_rfc-doc-quality-checklist.md`:
YAML frontmatter, Diataxis structure, multi-level diagrams, resolvable links,
no fabricated sizing, incorporate findings without asking.

### REVIEW mode — findings report

Write to `arch-review-<system-slug>.md`. Template:
`references/findings-report-template.md`. Sections: Header → Context Block →
Executive Summary (3–5 sentences, biggest risk) → Critical Findings
(severity-ordered, per-finding: Lens, Where, Problem, Failure mode,
Recommendation, Effort) → Assumptions table → SPOF Map → Prioritised Actions →
What the Design Gets Right.

No padding, no hedging. Quote document location for every finding.

### WRITE mode

Author: overview, non-goals, constraints, proposed architecture (mermaid),
design decisions + alternatives, failure modes, scalability, security,
observability, rollout, open questions, delivery phases. Self-review through
Step 3 lenses before presenting. Format via `wk-markdown`.

## Step 5: Interactive HTML Playground

Offer when ≥4 components or non-obvious failure cascades.

- Self-contained `arch-review-<slug>-playground.html`; inline CSS/JS.
- Required: architecture diagram, failure injection (click node → downstream red),
  blast-radius sidebar, gotchas panel (cycles findings).
- Graph as `const NODES/EDGES/FINDINGS` data block.
- Verify renders: `open` (macOS); Playwright snapshot when available.

---

## Post-Completion

Invoke `wk-learn arch-review`.
