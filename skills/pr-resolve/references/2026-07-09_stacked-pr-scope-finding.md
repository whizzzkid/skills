---
date: 2026-07-09
slug: stacked-pr-scope-finding
---

- **Rule:** When a finding says docs/comments describe behavior the diff
  doesn't implement, check the PR body's stack/follow-up section for a
  sibling PR that owns that behavior before treating it as a code gap. A
  sibling owns it → reword to future tense naming the follow-up PR; no
  sibling → implement it as a normal code gap.
- **Why:** Pulling deferred scope forward to satisfy a docs-vs-code finding
  breaks the stacking plan and bloats the current PR — the "missing"
  behavior was deliberately deferred, not overlooked.
- **Where:** `Step 4 → Docs-ahead-of-code, stacked PR` in `wk-pr-resolve`
  SKILL.md.
