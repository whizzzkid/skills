---
skill: wk-retro
date: 2026-08-11
type: pattern
severity: low
verified-against-source: n/a
---

Retro captured three workflow-phase gaps in one session

**What happened:** Session retrospective revealed three mandatory wk-workflow phases were skipped: Phase 1 (wk-plan), Phase 2 (wk-commit), and the Phase 1 invocation of wk-workflow itself.

**Root cause:** (unverified — inferred from symptom) The agent started implementing immediately on a seemingly simple task (fix a test assertion) without following the mandated workflow. The "auto mode + unambiguous directive" clause in wk-plan only waives the approval wait, not the plan creation itself.

**Suggested fix:** Reinforce that wk-workflow Phase 1 (wk-plan) is size-independent and mandatory. The retro log format (two buckets: "What worked" / "What could've been better") correctly surfaced these as actionable gaps.