---
class: principle
---

# A waived gate is not a gate to build an environment for

**Rule** — An explicit user waiver of local validation short-circuits environment
provisioning. Check for one before starting any container, devcontainer, or
runner; never build an environment to satisfy a gate the user removed. Name what
stays unverified instead of silently narrowing the report.

**Why** — The environment-selection HARD RULE mandated inspecting and using a
documented project container before the first build/lint/test, with no exception
for the case where the validation it enables has already been waived. Read
literally, the rule sends the agent to provision a full container stack in order
to run checks nobody asked for. A waiver narrows the *gate*; it must not narrow
the *reporting*, so the unverified surface is stated rather than dropped.

**Where** — `skills/workflow/SKILL.md` → Phase 3 → *HARD RULE: select execution
environment before validation*, as the bullet immediately after the
documented-container rule it qualifies.

## Second lesson from the same source: set invariants on data-only changes

**Rule** — For a data-only configuration change, compare the published set's
membership and count before and after. A diff read alone is not verification.

**Why** — Asserted as a practice that worked, so no escalation applies, and Phase
3 carried nothing about it: its verification bullets covered transformations,
lint, and gate ordering, all of which pass while a scoped config edit ships a
wrong set. Reading the diff confirms what changed, never what the resulting set
*is* — the property that actually matters when the data is the deliverable.

**Where** — `skills/workflow/SKILL.md` → Phase 3 → Verification, beside the
formerly-failing-input rule (both are "verify the outcome, not the edit").
