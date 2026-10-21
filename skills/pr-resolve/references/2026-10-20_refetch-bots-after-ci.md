---
class: principle
source: learnings/skills/pr-resolve/2026-10-20_refetch-bots-after-ci.learned.md
date: 2026-10-20
severity: medium
---

## Re-fetch threads after CI goes green — bots re-review every push

After pushing a fix and seeing green CI, the run reported done without re-running the thread fetch. The
review bot had re-reviewed the new head and posted a blocking finding, surfaced only when the user asked.

**Root cause:** the CI watch started several calls after the push, and the post-CI Step 3 re-run was
skipped. The rule (Step 9.5 "CI passes → re-run Step 3") was already installed, so this is a re-violation.

**Escalation:** baseline prose → `**Important:**` (one rung), plus the missing trigger clause: start the
CI watch in the same turn as the push so the re-fetch is tied to the watch's completion, and name bot
summary comments as part of the re-fetch.

**Landed in:** `SKILL.md` Step 9.5.
