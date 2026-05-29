# Review Lenses — Exhaustive Probe List

The SKILL.md carries the summary. This file is the deep checklist. Apply every
probe that is relevant to the system under review. Each probe is phrased as a
question the reviewer must be able to answer from the document — if it can't be
answered, that gap is itself a finding.

## Lens A — Single Points of Failure

- Which components have no redundancy (single instance, single replica, single AZ)?
- Is the primary datastore replicated? Is failover automatic or manual? Tested?
- Do message queues have redundant consumers, or does one consumer group own all throughput?
- Is there a shared cache whose loss causes a stampede onto the origin?
- Does the CDN origin-pull chain have a fallback origin?
- Is DNS resolution a dependency with a single provider / single zone?
- Is there a cron/scheduler whose downtime silently stops critical work?
- Is auth a monolith that gates every request?
- Is there a single CI/CD pipeline that, if broken, blocks all deploys (including the fix)?
- Is the control plane multi-region, or is one region the brain for all?
- Is there exactly one secrets store / KMS in the hot path?
- For each SPOF: blast radius at 5 min, 30 min, permanent loss?

## Lens B — Unhappy Paths

- Downstream call times out — what is the timeout, and what does the caller do?
- A dependency returns 5xx / malformed data — fail open or fail closed?
- A queue backs up past its retention window — is data lost? Detected?
- A deploy is partially rolled out — can v1 and v2 coexist (schema, contract)?
- A data migration fails mid-flight — is it resumable? Reversible? Idempotent?
- A third party changes its API contract without notice — blast radius?
- Clock skew across nodes — does any logic assume synchronised clocks?
- A message is delivered twice — is every mutation idempotent (idempotency key)?
- Are retries bounded (budget, max attempts) with exponential backoff + jitter?
- Are circuit breakers specified for every remote dependency?
- Is there a dead-letter path for poison messages?

## Lens C — Underlying Assumptions

- List every assumption not explicitly stated and evidenced.
- Tag each: Verified (evidence in doc) / Unverified (needs validation) / Risky (high-impact if wrong).
- Common traps: reliable network; bounded payload size; third-party SLA met;
  stable read:write ratio; synchronised clocks; single-region latency; team
  velocity; data fits in memory; eventually-consistent reads are acceptable to
  the product.

## Lens D — Scalability & Performance

- Where is the first bottleneck at 10× load? At 100×?
- Any hot partition / hot key / celebrity problem in storage or sharding?
- Any O(n) / O(n²) operation hiding in a fan-out, join, or per-item loop?
- Are connection-pool sizes and thread/worker budgets stated and bounded?
- Thundering herd on cold start, cache eviction, or mass reconnect?
- Does backpressure propagate, or does an upstream buffer unboundedly?
- Write amplification (one logical write → N physical writes / index updates)?
- Are reads served from replicas, and is replica lag acceptable to the product?

## Lens E — Security & Trust Boundaries

- Map every trust boundary crossing (internal↔external, service↔service, authn↔authz).
- Is sensitive data (secrets, PII, tokens) ever in logs, caches, queues, or URLs?
- SSRF risk on any URL-fetching or webhook component?
- Injection (SQL/NoSQL/command/template) at any input boundary?
- Confused-deputy / IDOR — does a service act on caller-supplied identifiers without authz?
- Blast radius of one compromised service — lateral movement, credential scope?
- Is least privilege enforced on every credential and IAM role?
- Is data encrypted in transit and at rest where the threat model requires it?

## Lens F — Operability & Observability

- For each Lens B failure mode: are there metrics/traces/logs to diagnose it?
- Is there graceful degradation (shed load, serve stale) vs. all-or-nothing?
- Zero-downtime deploy, rollback, and re-deploy — all three?
- What on-call runbook surface does the design imply? Is it bounded?
- Are there feature flags / kill switches for risky or new paths?
- Are SLOs defined with error budgets, and alerts tied to them (not to raw metrics)?

## Lens G — Cost & Efficiency

- Always-on compute for bursty workloads (candidate for autoscale / serverless)?
- Cross-AZ and cross-region data-transfer cost on hot paths?
- Storage class and retention — paying premium for cold data?
- Per-request cost at target scale — does unit economics work?
- Is there a cost ceiling and an alerting strategy on spend anomalies?

## Lens H — Delivery Risk

- External dependencies on the critical path (3rd parties, other teams, hardware, procurement)?
- Unproven technology choices that add discovery (not just execution) risk?
- Is the plan phased into independently shippable, verifiable milestones?
- What is the minimum viable slice that validates the single riskiest assumption first?
- Is the estimate bottom-up (tasks) or top-down (wishful)? Where is the padding / the optimism?
- What is the critical path, and what is its longest-pole task?
