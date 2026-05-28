---
skill: wk-slack
date: 2026-05-28
type: gap
severity: high
---

Standup snippets must follow a strict nested-list structure with exactly one link per bullet.

**What happened:** The standup snippet was generated as flat text, then as flat bullets, then with multiple links per bullet, before arriving at the correct nested structure through repeated user corrections.

**Root cause:** wk-slack had no explicit standup structure spec. The correct structure is:

```
• Yesterday:
  • Achievement 1  [repo#PR]
  • Achievement 2  [link]
  • Merged:
    • [repo#NNN] — description
    • [repo#NNN] — description
• Today:
  • Priority 1  [link]
  • Group (e.g. Merge Party):
    • [repo#NNN] — description
• Blockers:
  • Blocker description  [link]
```

Rules:
- Yesterday/Today/Blockers are top-level bullets; all sub-items nest one level deeper.
- Each bullet contains **at most one external link**.
- Groups of related artifacts (merged PRs, PRs to review) get a parent bullet + sub-listed children, one per artifact.
- GitHub PRs always labeled `repo#number` (e.g. `{repo}#NNN`), never bare `#NNN`.
- When building a copy button, emit `text/html` with `<ul><li>` nesting and real `<a>` tags.

**Suggested fix:** Add a "Standup Snippet" section to wk-slack with the above structure spec and rules as explicit HARD RULEs. Reference this section from wk-goodmorning's standup generation step.
