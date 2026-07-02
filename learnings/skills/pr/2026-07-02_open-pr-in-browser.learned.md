---
skill: wk-pr
date: 2026-07-02
type: correction
severity: medium
---

`gh pr view --web` was skipped after `gh pr create`; the user had to ask "did you open the PR you created?".

**What happened:** After creating the draft PR, the flow jumped straight to
description sync / self-review / CI poll and never opened the PR in the browser.
The user caught the omission with a direct question.

**Root cause:** The "open it in the browser first" instruction sits as a prose
bullet under Step 3, easily skipped under the momentum of continuing the
post-creation lifecycle. It is not gated as a hard structural step, so context
pressure drops it.

**Suggested fix:** Make `gh pr view --web` the FIRST unconditional action in the
same response that runs `gh pr create` — bind them as a single atomic step
("create then immediately open"), not a separate bullet. Skip only in a
confirmed headless/non-interactive session.
