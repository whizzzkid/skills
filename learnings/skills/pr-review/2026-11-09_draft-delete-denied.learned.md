---
skill: wk-pr-review
date: 2026-11-09
type: gap
severity: medium
verified-against-source: n/a
---

Delete+recreate of the user's own pending draft can be denied by an auto-mode permission classifier.

**What happened:** Phase 5's append path (delete own pending review, recreate with the union) hit a permission denial on the DELETE call, stalling the post until the user explicitly authorized it.

**Root cause:** The skill treats deleting the user's own pending draft as routine, but permission layers classify it as an external destructive write.

**Suggested fix:** When an own pending draft exists, state in the Phase 4 summary that posting will delete and recreate it, so the user's go-ahead covers the DELETE up front; on denial, report the payload path and ask once.
