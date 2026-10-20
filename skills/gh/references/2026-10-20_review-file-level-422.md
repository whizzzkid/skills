---
class: principle
source: learnings/skills/gh/2026-10-20_review-file-level-422.learned.md
date: 2026-10-20
skill: wk-gh
---

**Rule** — Never put a file-level or anchorless item in a create-review `comments[]` payload. Off-diff findings go in
the review body; a live file-level comment uses the single-comment endpoint and publishes immediately.

**Why** — Draft review comments accept only line/position anchors: `subject_type: file` returns 422 (`subjectType not
defined on DraftPullRequestReviewComment`) and an omitted anchor returns `position expected not null`. Two caller skills
prescribed "convert to file-level (omit `line` + `side`)" inside the review payload, which is exactly the failing shape;
both were corrected in the same fold.

**Where** — `SKILL.md` → Step 3; `references/github-api-surfaces.md`; callers `wk-self-review` Step 3.5 and
`wk-pr-review` valid-positions rule.
