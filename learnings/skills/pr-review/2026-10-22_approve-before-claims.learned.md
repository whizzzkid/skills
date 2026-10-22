---
skill: wk-pr-review
date: 2026-10-22
type: correction
severity: high
verified-against-source: n/a
---

Light+approve run submitted APPROVE before validating pr_claims, reviewing bot comments, or running wk-learn.

**What happened:** The agent ran tests and spot-checked corpus SHAs, then approved. It skipped marking each
description claim Confirmed/Refuted/Unverified, the Phase 2 bot-comment pass, and post-completion wk-learn. The user
caught it; the re-run found no refuted claims, but the approval had already been submitted irreversibly.

**Root cause:** Light mode's short time box was read as permission to skip phases, when the skill only defers the
adversarial dispatch. The approve gate does not list "every claim marked" as a precondition, so nothing blocked it.

**Suggested fix:** Add to the approve gate: "every pr_claims item marked Confirmed/Refuted/Unverified, and Phase 2
completed" as hard preconditions. Also note: a three-dot compare on a merged PR includes base-merge noise, so verify
"fixed by author" claims by reading the cited file at the PR's final head, not by file-list diffing.
