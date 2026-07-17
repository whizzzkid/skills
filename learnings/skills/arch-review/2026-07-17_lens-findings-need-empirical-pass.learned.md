---
skill: wk-arch-review
date: 2026-07-17
type: gap
severity: high
---

Lens-based findings on executable logic are hypotheses, not conclusions — run the logic before handing findings back.

**What happened:** Reviewing a spec whose core was a deterministic matcher, the eight-lens pass produced findings by reasoning about behavior, and I handed those back as the review result. The caller (a PR review) composed comments straight from them. Only when the user asked "did you simulate this?" did I drive the real matcher with adversarial inputs — which proved the flake vectors AND surfaced a finding the static pass never named (two orthogonal knobs coupling to void a genuine catch).

**Root cause:** The lenses generate strong hypotheses but never execute anything, so emergent interactions and exact break points stay invisible. Returning lens output as "the review" lets a downstream skill treat un-run reasoning as validated, and the arch-review path has no step forcing an empirical check before it returns.

**Suggested fix:** When the reviewed doc describes executable logic (matcher, grader, parser, state machine, algorithm) — especially one that names a concrete existing implementation — add a mandatory empirical step before returning findings: drive the real implementation (or a minimal faithful harness) with adversarial/edge inputs and record actual PASS/FAIL. Mark any finding you could have tested but only argued as Unverified. Lens C already says "read the runtime to confirm config-declared behavior" — extend that from *reading* the runtime to *executing* it for logic-bearing specs.
