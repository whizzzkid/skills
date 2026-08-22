---
class: principle
source: learnings/skills/buildkite/2026-08-22_conflate-trigger-with-cause.md
date: 2026-08-22
---

## Trigger vs. Cause in CI Failure Reports

- **Trigger:** the user's merge/push initiated this build run.
- **Cause:** the failure inside that build is attributable to their diff's content.

These are independent facts. A build can be triggered by the user's action while the failure is pre-existing, infra, or flaky. Collapsing them into a single "unrelated" verdict omits the trigger acknowledgment, which contradicts the user's correct observation.

## Folded Into

- `SKILL.md` → Investigating Failures, step 6
- Quick Reference → "Post-merge build fails, failure unrelated to diff"
