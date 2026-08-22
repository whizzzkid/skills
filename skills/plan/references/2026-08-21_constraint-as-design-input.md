---
class: principle
---

**Rule** — A documented performance or architectural constraint (no live aggregates,
read-replica-only, query-budget cap) is a design input the plan must satisfy, not a risk
to acknowledge. When the plan proposes a new query or operation on the request path, check
the codebase for a constraint governing that class of operation; when one exists, the plan
must adopt the same mitigation pattern the existing code uses.

**Why** — Noting a constraint in the risk section while proposing a step that violates it
is internally inconsistent. The planner stopped at "what data do we need" without asking
"how does existing code solve the same class of problem." The Ops/Platform persona probe
now asks this question explicitly.

**Where** — Step 2 Ops/Platform persona bullet + Common Mistakes entry.
