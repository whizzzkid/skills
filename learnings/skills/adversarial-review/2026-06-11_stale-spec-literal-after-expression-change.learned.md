---
skill: wk-adversarial-review
date: 2026-06-11
type: gap
severity: high
---

Sweep 2.8 must grep spec files for changed expression literals, not just source files.

**What happened:** A multi-line jq expression replaced a single-line literal. The rspec file contained `include("jq -r '.slack_discussion[]?, .tickets[]?'")` — an exact-string assertion on the old expression. The adversarial review's cross-doc sync sweep (2.8) did not grep `spec/` for the removed literal, so the stale assertion was not flagged. CI caught it on the next push.

**Root cause:** Sweep 2.8's synonym/removed-term audit targeted `docs/` and `README*` but not `spec/` and `test/` files. Spec files that assert source-code content (structure tests, grep-based specs) contain exact literals from the production source — they are enumeration surfaces just like docs. A changed expression that is also the subject of a `include(...)` / `grep -q` spec assertion produces a stale literal in the spec, which is functionally a broken test.

**Suggested fix:** Extend the sweep 2.8 removed-term grep to include `spec/` and `test/` directories explicitly. When any string literal is removed or replaced in a diff, run the variant grep against `spec/**`, `test/**`, and `*_spec.*` / `*_test.*` glob patterns in addition to `docs/` and `README*`. A hit in a spec file is a blocker — the spec is asserting the old form and will fail CI.
