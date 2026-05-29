---
skill: wk-pr-review
date: 2026-05-29
type: pattern
severity: medium
---

Verify architecture claims against source code, not just the spec's prose.

**What happened:** A re-review of a spec PR where the author claimed ".graphql gating is advisory, engine does no dispatch." Rather than trusting the reply, the review independently confirmed the claim by reading the relevant Ruby method and grepping for frontmatter parsing — finding none, which validated the spec's correction.

**Root cause:** Spec PRs often contain claims about how the surrounding system works. A re-review that only checks the spec's prose against itself misses whether the factual claims about the codebase are accurate.

**Suggested fix:** During re-review of spec/design PRs, when the author's fix involves a claim about system behavior (e.g., "engine does X"), verify the claim against the relevant source file before acknowledging the thread as resolved — not just the spec wording.
