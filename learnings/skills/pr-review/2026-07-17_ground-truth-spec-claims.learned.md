---
skill: wk-pr-review
date: 2026-07-17
type: pattern
severity: medium
---

Ground-truthing a design spec's code claims against the actual runtime caught a factual inaccuracy the doc read as settled.

**What happened:** Reviewing a doc-only design spec, I dispatched a subagent to verify each concrete code claim (structs, function signatures, existing fields, concurrency model) against the repo before drafting comments. One claim — that a new LLM draft call would ride "the existing concurrent fan-out" — was false: the component's concurrency was HTTP-I/O-only with no existing LLM subprocess, so the proposed work introduced a brand-new dependency rather than extending one. That became the second-strongest review finding and reframed a delivery-phase scope.

**Root cause:** Spec prose describing "existing" infrastructure is an assertion, not a fact; a reviewer who takes it at face value inherits the author's error and under-scopes downstream phases. Doc-only diffs tempt a reader to skip code verification because "there's no code to check."

**Suggested fix:** For spec/design-doc reviews, treat every claim about existing code (named structs/fields, "reuses X," "within the existing Y," effort estimates like "~N-line port") as Unverified until grep/read confirms it — delegate the batch to one verification subagent. Also: when a later tool result (e.g. a proactive grep expansion) appears to contradict a finding you already posted, re-verify immediately rather than letting the posted concern stand on stale evidence.
