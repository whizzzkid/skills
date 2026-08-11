---
skill: wk-plan
date: 2026-08-11
type: gap
severity: high
verified-against-source: yes
---

Plan phase skipped entirely before implementation

**What happened:** Made code changes (fixed test assertion, regenerated assets) without creating an approved plan via wk-plan. The fix was small but wk-workflow mandates wk-plan invocation before any Edit/Write/Bash write-action.

**Root cause:** Did not follow wk-workflow Phase 1 which explicitly invokes wk-plan before planning. Treated the task as "obvious/small" and waived the plan requirement, which wk-plan forbids: "Size-independent in BOTH directions: neither 'small/2-line/obvious' nor 'large/exciting/obviously-right — let me build' (momentum) waives it."

**Suggested fix:** wk-plan's auto-mode-approval rule only applies when the user's original message contains a clear imperative AND the plan executes exactly that. Still must present the plan and wait for approval (or proceed in same turn for auto-mode). Never skip the plan step.