---
class: principle
---

- **Rule** — The "captures match HEAD" rule covers every capture shared anywhere — PR body, docs, or a hand-off to the
  user — not only the ones a PR body lists. After a commit that changes rendered output, re-run the single capture
  script for all of them, overwrite, and delete superseded files before claiming the fix.
- **Why** — The user judged the fix from images they opened directly, not only from the PR body. A capture shared in a
  hand-off message or doc carries the same authority as a PR-listed one, so scoping the re-shoot to the PR body leaves
  a stale-evidence path open.
- **Where** — `SKILL.md` → Phase 3.6 (Frontend Live Preview), the "Every capture shared" bullet. Classified `partial`:
  the same-incident fold already required one re-runnable capture script, overwrite, and deletion of superseded files,
  but scoped them to PR-listed screenshots and set no point before which the re-shoot must land.
- **Rejected / deferred** — "Pair each re-shoot with a measured assertion" is already covered by the adjacent
  measured-property bullet in Phase 3.6, so no new text. "Create a `wk-playwright` skill" is a new-skill proposal, not
  a fold; ownership resolves to `wk-workflow` Phase 3.6, which owns Playwright-driven visual verification.
