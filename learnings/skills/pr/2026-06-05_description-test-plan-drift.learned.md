---
skill: wk-pr
date: 2026-06-05
type: gap
severity: medium
---

PR description shipped without a Testing/verification section; a description-check bot flagged that reviewers couldn't tell whether the new CI step and pre-commit hook were exercised.

**What happened:** A PR adding a CI check and a pre-commit hook used a repo template (What/Why/How/Meta) that has no Testing section. The body documented what changed but never stated how the change was verified (formatter clean, hook run locally, pipeline template rendered). A review bot raised a "description-check / Testing section missing" finding.

**Root cause:** wk-pr's template-population step fills the repo template's existing sections but does not guarantee a verification/test-plan section exists. When the repo template lacks one, the PR ships with no record of how the change was exercised — a recurring reviewer-bot flag.

**Suggested fix:** In wk-pr's "Resolve PR Body Template" step, after populating the repo template, verify a Testing/verification section is present. If the template has none, append a `## Testing` (or `## Test plan`) section listing the concrete checks run (commands + outcomes: linters/formatters clean, hooks run locally, CI template render, manual steps). Treat a missing verification section as drift to fix before `gh pr create`, not after a bot flags it.
