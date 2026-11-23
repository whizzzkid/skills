---
class: principle
source: learnings/skills/pr-review/2026-11-23_test-runner-from-makefile.learned.md
date: 2026-11-23
skill: wk-pr-review
---

**Rule** — Before replaying an empirical claim, take the test runner from the repo's documented entrypoint (Makefile
target, CI step, package script). A failed invocation of the wrong runner does not spend the claim's one `light` run.
Test-count claims go stale across fix-up commits, so check them at the head commit.

**Why** — A light-mode replay first tried a runner that was not installed while the repo's test target used a different
one; the rerun found more tests than the description claimed.

**Where** — `SKILL.md` → Phase 1 Claims, empirical-claims sub-bullet.
