---
skill: wk-pr-review
date: 2026-11-23
type: gap
severity: medium
verified-against-source: yes
---

Ownership/gating claims ("can't change without X's review") need the branch ruleset and bot-approval behavior checked, not just CODEOWNERS syntax.

**What happened:** A PR claimed CODEOWNERS made a team the sole gate for rule files. The ruleset had require_code_owner_review:false and bot approvals satisfied the single required review, so the claim was false. A separate prompt-level "skip if base branch isn't default" rule turned out to read an env var that is always empty in API-triggered CI builds; a verifier reading the real build job env found it, where reasoning about PR event triggers did not.

**Root cause:** The skill's claim-verification guidance covers empirical and cited-figure claims but not governance claims, and doesn't push verifiers to inspect real production run inputs for context fields a prompt relies on.

**Suggested fix:** In Phase 1 claims: governance/ownership claims → read effective branch rules (require_code_owner_review, required count) plus codeowners/errors, and check recent merges for bot-only approvals. In Phase 3: a prompt/check that branches on a context field → verify the field's value in a real production run's inputs, not only the code that sets it.
