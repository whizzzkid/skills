---
skill: wk-pr-resolve
date: 2026-06-12
type: correction
severity: high
---

After CI passes, automatically re-fetch all comment surfaces and continue the loop — do not stop and return control to the user.

**What happened:** CI went green after a push. Agent stopped and reported success. New bot comments from that CI run were left unaddressed until the user explicitly re-invoked /wk-pr-resolve.

**Root cause:** Agent treated "CI green" as the terminal condition instead of "CI green AND zero unresolved threads." The skill contract is to loop until the PR is mergeable, not until CI passes.

**Suggested fix:** After every CI green confirmation, always re-fetch all three comment surfaces (inline threads, review bodies, issue comments), triage any new threads using the full triage flow, implement approved fixes, push, and loop again. Only stop when CI is green AND thread count is zero. Never return control mid-loop because CI happened to be green.
