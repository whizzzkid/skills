---
class: principle
date: 2026-05-27
severity: medium
---

- **Rule:** When a changed file is `.md` and the diff adds >50 lines, stage an inline comment on the first in-hunk line linking the GitHub rendered preview.
- **Why:** Reviewers read raw diffs by default; large markdown changes are hard to parse without the rendered view.
- **Where:** New sub-section in Step 2 ("Markdown preview link for large diffs"), uses Step 3.5 line-validation.
