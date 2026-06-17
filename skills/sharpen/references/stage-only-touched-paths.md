---
class: principle
---

# Stage only run-touched paths — never blanket `git add -A`

**Rule**

- In Step 8, stage only the paths this run touched: edited `SKILL.md`/`README.md`/
  `references/`, version bumps, and the specific learning/retro files this run
  processed and renamed to `.learned.md`.
- Never blanket `git add -A`. If unavoidable, `git reset` every `learnings/`/
  `retrospect/` path this run did not process before committing.

**Why**

- The working tree routinely carries *unprocessed* inbox learnings/retros from
  other sessions. `git add -A` bundled them into an unrelated single-incident
  commit; they had to be `git reset` back out.
- "Every dirty file" was the prior wording and actively invited the over-stage.

**Where**

- `skills/sharpen/SKILL.md` Step 8, item 2.
