---
skill: wk-pr-resolve
date: 2026-06-12
type: correction
severity: medium
---

Push commits first, then update the PR body — never update the body as a pre-push blocker.

**What happened:** Adversarial review 2.10 flagged stale PR body references as blockers. Agent updated the PR body before pushing, treating it as a pre-push gate.

**Root cause:** The 2.10 sweep correctly identifies stale refs, but the fix belongs after push — the body describes what is live in the PR, and the commits aren't live until pushed. Updating before push is premature and inverts the causal order.

**Suggested fix:** In the adversarial review pre-push pass, note PR body stale refs as a post-push TODO rather than a blocker. After push succeeds, update the body to reflect the new HEAD. The sequence is: implement → commit → push → update PR body → re-fetch comment surfaces.
