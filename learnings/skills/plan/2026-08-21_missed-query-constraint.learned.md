---
skill: wk-plan
date: 2026-08-21
type: gap
severity: medium
verified-against-source: yes
---

Plan noted a documented "no live COUNT/GROUP BY on the request path" constraint in the risk section but still proposed a live GROUP BY query for a new feature, only catching it when the user asked.

**What happened:** During Phase A planning, identified that the codebase's KPI module explicitly documents a no-live-aggregate constraint and that the existing data layer uses a HotStore Redis cache + periodic Sidekiq flush pattern. Despite noting the constraint as a "risk," the plan's Step 5 proposed a live GROUP BY query — contradicting the very constraint it cited.

**Root cause:** The plan treated the constraint as a risk to acknowledge rather than a design input to satisfy. The existing caching pattern (HotStore + `CheckMetricsFlushJob` + `with_fallback`) was visible in the research but was not applied to the new query because the planning pass stopped at "what data do we need" and never asked "how does existing code solve the same class of problem."

**Suggested fix:** Add a probe to wk-plan Step 2 (Multi-Persona Validation) under the Ops/Platform persona: "For every new query on the request path, check whether the codebase documents a query-budget constraint (e.g., no live aggregates, no N+1, read-replica-only). When one exists, the plan must use the same mitigation pattern the existing code uses — never propose a live query and defer the constraint to a risk note."
