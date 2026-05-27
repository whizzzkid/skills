---
class: principle
---

- **Rule**: For diffs where every changed file is documentation, prompt/rule text, or non-executable fixture data, substitute a read-based adversarial analysis in `.review-playground/` for scratch scripts and mutation tests.
- **Why**: Phase 4's executable experiments assume runnable code; markdown rules and eval fixtures are LLM-read, not interpreter-run — scratch scripts and mutations don't apply.
- **Where**: wk-pr-review Phase 4, "Documentation-only diff — substitute read-based analysis".
