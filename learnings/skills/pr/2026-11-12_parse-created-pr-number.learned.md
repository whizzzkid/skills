---
skill: wk-pr
date: 2026-11-12
type: correction
severity: medium
verified-against-source: n/a
---

Take the PR number from the `gh pr create` output, never from a guess.

**What happened:** After creating a stacked PR, the agent wrote a predicted next number into a ticket comment and a CI watch. The printed URL showed a different number because other PRs had opened in between, so both pointed at someone else's PR until it was caught.

**Root cause:** The agent extrapolated the number from the previous PR in the session instead of reading the create command's stdout.

**Suggested fix:** In Step 2, capture the URL from `gh pr create` stdout into a variable and derive the number from it, before any follow-up (ticket comment, CI watch, self-review). This restates Hard Rule 4 for the number itself.
