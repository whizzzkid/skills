---
skill: wk-workstyle-typescript
date: 2026-07-28
type: correction
severity: low
verified-against-source: yes
---

Guard both null and undefined after optional chaining before dereferencing the result.

**What happened:** A strict TypeScript check rejected a fixture helper because an optional-chained
query result was checked for null but not undefined.

**Root cause:** Optional chaining widened the query result to include undefined, while the explicit
guard covered only the DOM query's null branch.

**Suggested fix:** Add optional-chain narrowing to the TypeScript checklist and prefer an explicit
null-or-undefined guard before dereferencing values produced through optional chaining.
