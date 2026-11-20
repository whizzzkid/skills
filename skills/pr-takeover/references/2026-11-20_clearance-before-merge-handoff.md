---
class: principle
source: learnings/skills/pr-takeover/2026-11-20_clearance-before-merge-handoff.learned.md
date: 2026-11-20
skill: wk-pr-takeover
---

**Rule** — When a takeover directive ends in a merge, dispatch the adversarial review right after local validation
(before any light PR review) and list approvers up front; a bot-only approval is raised then, not at the merge call.

**Why** — A "validate, quick review, merge" directive on an inherited, approved PR went straight from a light review
(which never dispatches the adversarial review) to the merge skill, whose clearance gate found no record and stopped
mid-flow; the stop also surfaced that the only approval came from a bot.

**Classification** — `principle`, new Step 6 rule (the merge skill's clearance and bot-approval gates existed; the
takeover flow never front-loaded them).

**Where** — `SKILL.md` → Step 6 (Plan Remaining Work); README Key Phases.
