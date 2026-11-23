---
skill: wk-plan
date: 2026-11-20
type: correction
severity: medium
verified-against-source: yes
---

Offered a live-test target without probing whether it could produce the test's precondition.

**What happened:** While asking the user to pick a live-test target for a merge-permission hook, the agent offered "a
throwaway PR in this repo; the review bot approves it". The user picked it. A later probe showed the repo has no
review bot and no branch protection, so a PR there gets no bot approval and an empty review decision. The chosen
option could not reproduce the bot-only-approval scenario the test exists to exercise.

**Root cause:** The option was drafted from assumption. No read-only probe checked that the environment could
produce the precondition (a bot approval and a non-empty review decision) before it was offered.

**Suggested fix:** Before offering any test-environment option, run one read-only probe per precondition the test
needs (e.g. recent PR reviews by author type; the branch protection or ruleset API). Offer only options the probe
confirms. Unverifiable → label the option "unverified" in its description.
