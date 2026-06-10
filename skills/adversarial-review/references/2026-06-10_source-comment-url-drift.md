---
class: principle
date: 2026-06-10
skill: wk-adversarial-review
---

- **Rule:** When a source comment carries a download/API URL, grep README
  and docs for the same hostname/path and confirm they agree with the
  documented access mechanism; flag `blocker` on divergence.
- **Why:** A stale public-URL comment (copied from an example) drifts from a
  README that documents an authenticated/private download path; reviewers
  flag the inconsistency.
- **Where:** Sweep 2.4 (Comment accuracy pass), source-comment URL
  cross-check.
