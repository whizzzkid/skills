---
class: principle
date: 2026-05-28
source:
  - ~/.claude/memory/feedback_hook_scope_to_diff_not_whole_file.md
severity: medium
---

- **Rule** — scope a content-lint pre-commit hook twice: to the file class the rule governs, and to added diff lines (`git diff --cached -U0`), not whole staged files.
- **Why** — an over-scoped hook flags pre-existing content in files the commit only touched once, blocks unrelated work, and trains the author to `--no-verify`. Observed: a relative-link hook scoped to all `*.md` flagged 70 legacy refs in an instruction file it should never have scanned.
- **Where** — wk-workflow Phase 2 Code Standards, "Content-lint hooks — scope to file class and diff" subsection.
