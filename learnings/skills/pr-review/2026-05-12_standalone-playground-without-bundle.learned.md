---
skill: wk-pr-review
date: 2026-05-12
type: pattern
severity: medium
---

Replicate framework logic verbatim in a standalone Ruby script when the project bundle cannot be installed in the review environment.

**What happened:** Phase 4 playground needed to verify `Tools::Base#call` behavior against `RubyLLM::Tool#call`. Bundle was broken; Rails app couldn't boot. Instead, the framework's `call`/`validate_keyword_arguments`/`Halt` source was fetched from GitHub, re-implemented verbatim in a self-contained script, and run with the system Ruby (`ruby 4.0.1`).

**Root cause:** Worktree environments often lack database credentials and full gem installs required to boot a Rails app for playground experiments.

**Suggested fix:** Document this fallback pattern in Phase 4: for pure-Ruby logic reviews, a standalone script that re-implements the relevant framework methods from source is as rigorous as running the app and avoids boot dependencies entirely.
