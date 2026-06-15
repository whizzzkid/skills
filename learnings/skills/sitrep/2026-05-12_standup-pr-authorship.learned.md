---
skill: wk-goodmorning
date: 2026-05-12
type: correction
severity: medium
---

Standup "Yesterday" section included PRs the user did not author or contribute to.

**What happened:** A teammate's merged PR appeared in the user's standup under "Yesterday" achievements. The user merged the PR (as a maintainer) but was not the author, co-author, or reviewer.

**Root cause:** The GitHub agent returned all recently merged PRs and the orchestrator included them as achievements without filtering by authorship. Merging a PR is a maintenance action, not an achievement to claim.

**Suggested fix:** Standup "Yesterday" bullets must only include PRs where the user is: (a) the PR author, (b) a listed co-author, or (c) the primary/approving reviewer who drove the work to completion. Simply merging another person's PR — even as a maintainer — does not qualify. Apply the same filter in wk-sitrep end's brag/snapshot section.
