---
class: principle
---

# Resolve requires code fix — already covered

**Rule** — Never resolve a review thread via GraphQL without first reading and
addressing the underlying finding. Resolution requires a landed code fix, explicit
dismissal, or tracked deferral.

**Why** — Resolving without fixing hides feedback cosmetically; the finding stays
unaddressed in code.

**Where** — `SKILL.md` → Hard Rules → Rule 3: "Resolution requires a landed code
fix, explicit dismissal, or tracked deferral — in that order: implement fix → commit
→ push → resolve. Never resolve a thread to dismiss a finding; resolution means the
finding is addressed in code."

Classification: `already-covered` at HARD RULE level — no escalation room in the
label ladder (HARD RULE is structural, above rung 8). The existing rule fully covers
the reported violation.
