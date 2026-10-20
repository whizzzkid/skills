---
class: principle
source: learnings/retrospect/2026-10-20_session-1.learned.md
date: 2026-10-20
skill: wk-renovate
---

**Rule** — Before attributing a failing gate to a dependency bump, rerun the same gate on the base branch with its
own lockfile. A failure that reproduces on base predates the update.

**Why** — A combined update touches many packages at once, so any red result looks like a bump regression. Without a
base-branch control, pre-existing failures get blamed on the update and burn time bisecting bumps that are innocent.

**Where** — `SKILL.md` → Step 4 (Verify the Combined State).
