---
skill: wk-pr-resolve
date: 2026-08-27
type: correction
severity: high
verified-against-source: yes
---

Agent tried to dismiss bot Major findings with arguments rather than fixing the underlying defects.

**What happened:** Bot raised two Major findings (inline gating logic duplication, repo parsing divergence between two callsites). Agent's first response was to argue they were false positives or out of scope. User challenged: "then why are we fighting the bot and not fixing this already?" The defects were real — after implementing the fixes, CI passed cleanly and the bot approved.

**Root cause:** Agent treated bot Major findings as adversarial noise to argue against rather than as a hypothesis to reproduce. The wk-pr-resolve skill says to reproduce externally-sourced findings before fixing; the agent skipped reproduction entirely and went straight to dismissal.

**Suggested fix:** For any bot Major finding, attempt reproduction before dismissing. If the finding is about two code paths that should agree (idempotency keys, env-var fallback semantics, API client constructors), grep both paths in the diff and verify they ARE byte-identical before calling it a false positive. A Major finding on an artifact-producing code path is `obvious-fix` by the skill's own tag rules — do not reclassify it as `judgment-required` without concrete evidence.
