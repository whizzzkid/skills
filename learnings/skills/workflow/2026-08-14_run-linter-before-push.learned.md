---
skill: wk-workflow
date: 2026-08-14
type: correction
severity: high
verified-against-source: n/a
---

Run linter locally before every push to avoid repeated CI failures

**What happened:** Agent pushed code multiple times that failed RuboCop CI checks (SafeNavigationChainLength, ConditionalAssignment, MultilineOperationIndentation, IndentationWidth). User grew frustrated: "why are you making silly mistakes when like rubocop errors, when you should know that is the wrong way of doing this?" Each failure required another fix-commit-push cycle.

**Root cause:** Workflow skill does not enforce running the project linter (`bin/rubocop`) on changed files before `git push`. Agent relied on CI to catch lint errors instead of catching them locally.

**Suggested fix:** Add a mandatory pre-push step to the workflow: run the project's configured linter on all changed files before pushing. If it fails, fix and re-commit before pushing. This prevents the wasteful push-fail-fix-push loop.
