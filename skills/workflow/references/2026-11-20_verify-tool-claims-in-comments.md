---
class: principle
source: learnings/skills/workflow/2026-11-20_verify-tool-claims-in-comments.learned.md
date: 2026-11-20
skill: wk-workflow
---

**Rule** — A code comment stating what an external tool checks, passes through, or costs is a behavioral claim:
grep the tool's source for the mechanism (parser, CLI dispatch, plugin defaults) or drive it once against a scratch
copy before committing. Check plugin defaults (service dependencies, env propagation) before calling a step cheap or
isolated.

**Why** — CI-wiring comments claimed a validate command uniquely caught a failure class the loader already rejected,
called a passthrough "untouched" when the library rejected one key and shallow-merged defaults, and called a step cheap
while its container plugin still started and health-waited on unused services by default. All three came from docs and
intent, not source; adversarial review caught them.

**Classification** — `principle`, `partial`: extends the existing "verify mechanism before offering options" bullet,
which covered offered options but not comments.

**Where** — `SKILL.md` → Phase 1 interaction rules, "Verify mechanism" bullet.
