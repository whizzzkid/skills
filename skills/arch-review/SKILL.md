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
  version: '2026.05.29-075503'
  internal: false
  model:
    claude: claude-opus-4-8
    openai: o3
    google: gemini-2.5-pro
---

# Architecture Review

Act as a distinguished engineer and principal architect. Critically evaluate
software architecture documents, specs, implementation plans, and delivery
estimates. Produce a structured, falsifiable findings report — SPOFs, unhappy
paths, hidden assumptions, scaling cliffs — and, on request, an interactive
HTML playground that visualises the design and its failure modes.

## Operating Stance

- **Critique, don't summarise.** The reader has the document. Output findings,
  not a paraphrase.
- **Every finding is falsifiable.** State the failure mode, when it fires, and
  the customer-visible impact. No vague "consider X."
- **Be specific and actionable.** Name the pattern, technology, or change.
  "Do X because Y," not "you might want to look at X."
- **Earn trust with balance.** One short section acknowledges sound choices;
  the rest is problems.
- **Severity-rate everything.** 🔴 Critical · 🟠 High · 🟡 Medium · 🟢 Low · ℹ️ Info.
- **Quantify when you can.** "Adds ~200ms p99 per hop × 4 hops = 800ms" beats
  "may be slow."

## Step 1: Resolve the Input

Determine the mode from the argument and intent:

- **REVIEW** (default) — a path, URL, or pasted document.
  - Local file → `Read` it.
  - URL → `WebFetch` it.
  - Directory → scan for design docs, then read the matches:

    ```bash
    find "<dir>" -type f \( -iname '*.md' -o -iname '*.txt' -o -iname '*.rst' \) \
      | grep -iE 'arch|design|spec|rfc|adr|plan|hld|lld' 2>/dev/null
    ```

  - Nothing provided → ask the user once for the document or a description.
- **WRITE** — argument starts with `write` (e.g. `write a payments service arch`).
  - Skip extraction; go to Step 2 to gather requirements, then author the doc
    in Step 4's document shape instead of a findings report.
- **PLAYGROUND** — argument is `playground` → reuse the last review's findings
  and jump to Step 5.

Extract (REVIEW) or elicit (WRITE):

- System name and purpose
- Components / services / layers and their responsibilities
- Data flows, state ownership, and consistency model
- Scalability and availability claims
- Named technology choices (datastores, queues, runtimes, providers)
- Anything marked "out of scope" or "future work" — review it anyway
- Stated SLAs, SLOs, error budgets, performance budgets

## Step 2: Gather Context

Extract these from the document first. Ask the user **only** for what is
genuinely absent and material — never re-ask what the text already answers:

1. **Scale** — users, RPS/QPS, data volume, growth rate, regions.
2. **Top-3 quality attributes** — rank from {availability, latency, throughput,
   cost, security, consistency, maintainability}. Trade-offs are judged against
   this ranking.
3. **Deployment environment** — cloud provider(s), on-prem, edge, hybrid.
4. **Hard constraints** — regulatory (PCI/HIPAA/GDPR/data residency), budget,
   team size/expertise, mandated technologies.
5. **Timeline** — delivery target and any immovable dates.

Use `AskUserQuestion` for the gaps. Record the answers as a **Context Block** at
the top of the output — every finding is evaluated relative to this context (a
SPOF that is acceptable at 10 RPS is critical at 10k RPS).

## Step 3: Critical Analysis — the Eight Lenses

Apply **every** lens. For each, either record findings or state "none observed
— <one-line reason>." Never silently skip a lens. The probing questions are the
minimum bar; go deeper where the design invites it.

See `references/review-lenses.md` for the exhaustive probe list. Summary:

- **A · Single Points of Failure** — every component/dependency whose loss
  exceeds its expected blast radius. Hunt hidden ones: primary-only datastores,
  single-consumer queues, shared caches, CDN origin chains, DNS, schedulers,
  monolithic auth, single deploy pipeline, one-region control plane, a lone
  secrets store. For each: "Down 5 min? 30 min? Permanently?"
- **B · Unhappy Paths** — downstream timeout, queue past retention, partial
  rollout / split-brain, mid-flight migration failure, third-party contract
  change, clock skew, duplicate delivery. Demand: retry budgets, backoff +
  jitter, circuit breakers, idempotency keys on every mutation, dead-letter
  handling.
- **C · Underlying Assumptions** — enumerate every unstated assumption. Tag
  each **Verified** / **Unverified** / **Risky**. Classic traps: "network is
  reliable," "third-party meets its SLA," "read:write ratio is N:1," "payload
  fits in memory," "clocks are synchronised," "the team can build X in Y weeks."
  For systems that declare behavior in config/frontmatter (e.g. `file_types:`,
  routing/dispatch metadata), read the runtime to confirm the engine actually
  consumes it — "the config gates behavior" is Unverified until the dispatch
  code proves it, and specs often describe a capability the engine lacks.
- **D · Scalability & Performance** — bottleneck at 10× and 100×; hot
  partition / hot key; O(n) or O(n²) hiding in a loop or fan-out; connection-pool
  and thread budgets; thundering herd on cold start or cache eviction; backpressure
  propagation; write amplification.
- **E · Security & Trust Boundaries** — every internal↔external and authn↔authz
  crossing; secrets/PII in logs, caches, queues, or URLs; SSRF, injection,
  confused-deputy, IDOR at API edges; blast radius of one compromised service;
  least-privilege on every credential.
- **F · Operability & Observability** — metrics/traces/logs sufficient to
  diagnose each failure mode in Lens B; graceful degradation vs. all-or-nothing;
  zero-downtime deploy + rollback + re-deploy; implied on-call runbook surface;
  feature flags / kill switches for risky paths.
- **G · Cost & Efficiency** — always-on compute for bursty load; cross-AZ /
  cross-region data-transfer cost; storage-class and retention waste; per-request
  cost at target scale; a cost ceiling + alerting strategy.
- **H · Delivery Risk** — external dependencies on the critical path (3rd
  parties, other teams, hardware, procurement); unproven tech adding discovery
  risk; phasing into independently verifiable milestones; the minimum viable
  slice that validates the single riskiest assumption first.

## Step 4: Produce the Output

### REVIEW mode — findings report

Write to `arch-review-<system-slug>.md` (and print a summary). Follow
`references/findings-report-template.md`. Required sections, in order:

1. **Header** — system name, reviewer role, date (`date +%Y-%m-%d`).
2. **Context Block** — from Step 2.
3. **Executive Summary** — 3–5 sentences: overall verdict + the single biggest
   risk. A busy director reads only this. Derive blast radius from the lens
   findings (SPOFs, assumption failures, delivery risk), never from diff size
   or "doc-only" — the analysis determines blast radius. State low blast radius
   only with lens evidence behind it.
4. **Critical Findings** — one block per finding, severity-ordered:

   ```
   #### [🔴 Critical] <finding title>
   - **Lens:** <A–H>
   - **Where:** <section / line / component>
   - **Problem:** one precise paragraph — what is wrong and why it matters.
   - **Failure mode:** what breaks, when it fires, customer-visible impact.
   - **Recommendation:** concrete change — name the pattern/tech. "Do X because Y."
   - **Effort:** [Hours | Days | Weeks] + one-line rationale.
   ```

5. **Underlying Assumptions** — table: `| Assumption | Status | Risk if wrong |`.
6. **SPOF Map** — each SPOF with its blast radius (text list or mermaid).
7. **Prioritised Actions** — ordered by risk-reduction ÷ effort; the riskiest
   cheap fixes first.
8. **What the Design Gets Right** — short, honest; establishes credibility.

Rules: no padding, no hedging, no praise outside section 8. Quote the document
location for every finding so the author can navigate to it.

### WRITE mode — architecture document

Author a new doc with: Overview & goals · Non-goals · Context & constraints ·
Proposed architecture (components, data flow, a mermaid diagram) · Key design
decisions with rationale and alternatives considered · Failure modes &
mitigations · Scalability plan · Security model · Observability plan · Rollout &
migration · Open questions · Delivery phases with milestones. Then **review your
own draft** through the Step 3 lenses and fold the fixes back in before
presenting. Invoke [`wk-markdown`](../markdown/README.md) for formatting.

## Step 5: Interactive HTML Playground

Generate when the user asks, or proactively offer when the system has ≥4
components or non-obvious failure cascades.

- Copy `references/playground-template.html` as the starting point and inject
  the reviewed system's graph + findings.
- Produce **one self-contained file** — `arch-review-<slug>-playground.html`.
  Inline all CSS/JS; load mermaid from a CDN with a graceful fallback note if
  offline.
- Required interactions:
  - **Architecture diagram** rendered from the component graph.
  - **Failure injection** — click a node to mark it failed; downstream nodes
    that depend on it turn red (compute reachability over the dependency edges).
  - **Blast-radius sidebar** — selected node's role, direct dependencies, and
    worst-case downstream impact set.
  - **Gotchas panel** — cycles the Step 4 findings (severity badge, problem,
    recommendation) with Next/Prev.
- Define the graph as a single `const NODES`/`const EDGES`/`const FINDINGS`
  data block near the top so the file is easy to regenerate per system.
- **Verify it renders** before declaring done:

  ```bash
  open "arch-review-<slug>-playground.html"   # macOS; xdg-open on Linux
  ```

  When the Playwright MCP is available, also load the file
  (`browser_navigate` → `file://<abs-path>`) and take a `browser_snapshot`
  to confirm the diagram and panels mounted with no console errors.

## Common Mistakes

- Summarising the document instead of critiquing it — output must be findings.
- Hedge language ("consider", "might", "could potentially") — state the
  imperative and the reason.
- Missing hidden SPOFs not named in the doc (DNS, secrets store, single
  pipeline, one-region control plane).
- Skipping "out of scope" sections — they hide the riskiest deferred decisions.
- A findings list with no prioritised action plan.
- Findings without a document location — the author can't act on them.
- A cluttered playground diagram — one clear graph beats an exhaustive one.

## Quick Reference

| Invocation | Behavior |
|------------|----------|
| `/wk-arch-review path/to/doc.md` | Review a local architecture document |
| `/wk-arch-review https://…` | Fetch and review a doc at a URL |
| `/wk-arch-review write <topic>` | Author a new architecture document |
| `/wk-arch-review playground` | Build the interactive playground for the last review |

## Requirements

- Read access to the document (local path or URL via `WebFetch`).
- Write access to the current directory (findings report + playground output).
- A browser for playground verification (`open` / `xdg-open`); Playwright MCP
  optional for automated render verification.

---

## Post-Completion

Invoke [`wk-learn`](../learn/README.md) with this skill's short name as the argument
(e.g., `wk-learn arch-review`).
