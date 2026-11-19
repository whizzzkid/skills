---
class: principle
source: learnings/skills/pr-merge/2026-11-19_classifier-blocks-merge.learned.md
date: 2026-11-19
skill: wk-pr-merge
---

**Rule** — In auto mode, before the merge call, grep the user and project settings for an allow rule matching
`gh pr merge`. None → tell the user up front that the permission layer may refuse the merge even with a human
approval and green CI, and give the PR link (merge it themselves) or a `Bash(gh pr merge:*)` rule they add. Then
attempt the merge; a denial follows the existing classifier-denial edge case.

**Why** — Every gate passed (human approval, green required checks, clean merge state), yet the merge call was denied
as "merge without review". The pre-call warning covered only bot-only approvals, and the classifier-denial handling
only ran after the refusal, so the user had to come back and ask what to do.

**Classification** — `partial`: the post-denial handling (installed 2026-07-20) and the bot-only pre-call warning
(installed 2026-11-17) both stand; neither warns before the call when a human approved.

**Where** — `SKILL.md` → Step 6 (permission preflight bullet); README Noteworthy. Mechanism mirrors
`wk-self-review`'s permission pre-flight.
