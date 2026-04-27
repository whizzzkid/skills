---
skill: wk:sharpen
date: 2026-04-27
type: correction
severity: high
---

After a sharpen run, the agent edited skill files and renamed learnings but did not commit or push — Step 7's "Commit with a message describing the improvement" was silently skipped across multiple consecutive `/wk:sharpen` invocations.

**What happened:** Across three back-to-back `/wk:sharpen` runs in one session (idempotency gates for goodmorning/goodevening, Phase 6 discipline for workflow, PR-sync rule for commit), each run ended with edits applied and `npx skills add` executed, but with no `git commit` or `git push`. The user had to ask "were the changes committed?" to surface ~10 dirty files (4 SKILL.md edits, the .distilled-sources.log, 5 renamed learnings). Step 7 of `wk:sharpen` explicitly says "Commit with a message describing the improvement", but the skill file lists it as a sub-bullet under "Step 7: Apply the Update" — easy to read as informational rather than mandatory.

**Root cause:** Step 7 is presented as a four-bullet list (edit, re-read, bump, commit) that an agent in a hurry treats as "the bullet about applying the change," dropping the others. The skill has no terminal gate — no "you are not done until X is committed" check — so a routine run can exit clean without ever invoking `wk:commit`. Combine that with the user's continuous `/wk:sharpen` invocations and each new run started before the prior run's commit ever happened.

**Suggested fix:** Restructure Step 7 to make the commit step a separate, post-edit verification gate rather than a sub-bullet. Add an explicit "Step 8: Commit and verify clean working tree" with: (a) `git status --short` to enumerate dirty files from the edit, (b) invoke `wk:commit` with a descriptive message naming each updated skill and the principles distilled, (c) confirm `git status` is clean before declaring the run complete. In batch mode, commit once at the end covering all distilled skills + all renamed learnings + the log update — but always commit. The completeness check should fail loudly if files are still dirty.
