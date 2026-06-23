---
skill: wk-pr
date: 2026-06-23
type: correction
severity: medium
---

Wait for new CI run after every push before marking PR ready

**What happened:** Pushed a new commit to an existing PR, then marked it ready without waiting for the fresh CI run to complete. CI eventually passed, but the mark-ready action raced ahead of verification.

**Root cause:** Step 5 (Mark Ready) has a final adversarial-review gate that runs only on new commits. The new commits existed after the push, but I proceeded to `gh pr ready` while CI was still `running`. The hard rule says "after CI is green" — green must be verified first.

**Suggested fix:** After any push that lands new commits to a PR, always re-run the CI poll before `gh pr ready`. Do not assume a prior CI run satisfies the gate for a new set of commits. Each commit = each CI run must complete.
