---
skill: wk-workflow
date: 2026-08-11
type: correction
severity: high
verified-against-source: yes
---

Should invoke wk-workflow at session start before any implementation

**What happened:** Started fixing CI build failure without invoking wk-workflow first. Jumped straight to implementation (running tests, fixing code, creating PR) without following the mandated workflow phases.

**Root cause:** Skipped Phase 1 (Plan) of wk-workflow which requires invoking wk-plan before any code changes. The workflow skill is designed to be invoked on EVERY task producing code changes, with no size exemption.

**Suggested fix:** Add explicit reminder in wk-workflow that it must be the first skill invoked when starting any coding task. The HARD RULE "announce-and-invoke same turn" means the Skill tool call must be in the first response after receiving the task.