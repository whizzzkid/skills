---
skill: wk-pr-review
date: 2026-05-27
type: pattern
severity: low
---

For documentation-only PRs, skip live code execution in playground — read-based analysis is sufficient.

**What happened:** PR touched only markdown skill rules and eval fixtures (no runnable code). Phase 4 playground guidance calls for scratch scripts and mutation tests, but the rule is LLM-read documentation, not executable code. Attempted to create a playground analysis doc instead.

**Root cause:** Skill instructions assume code changes; playground examples (scratch scripts, mutation tests) don't apply to prompt/rule document changes.

**Suggested fix:** Add a conditional to Phase 4: when all changed files are documentation or eval fixtures (`.md`, `.json`, `.tsx` fixture-only), skip executable playground experiments and substitute a read-based adversarial analysis document in `.review-playground/`. Note that eval fixtures can still be validated by reading the matcher logic (`expectation_matcher.rb`) and tracing match behavior manually.
