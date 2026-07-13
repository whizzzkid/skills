---
skill: wk-pr
date: 2026-07-13
type: correction
severity: medium
---

Draft PR body shipped with the commit-trailer footer instead of the canonical wk-gh outbound footer.

**What happened:** The PR body ended with the commit-message trailer (`🦾 Generated with ... and multiple models.`) rather than the wk-gh canonical outbound footer (`<sup>Generated using ... and multiple agents/models. DM me your feedback.</sup>`). The self-review inline comments posted afterward used the correct outbound footer, so the two surfaces disagreed on the same PR.

**Root cause:** Both footers open with "Generated ... wk-skills", so they are easy to conflate. The commit trailer is for commit messages/PR-body *trailers* in wk-commit; the outbound footer is the wk-gh Step 4 requirement for every GitHub-posted body including the PR description. The wk-pr flow injected the wrong one at body-render time.

**Suggested fix:** In wk-pr, inject the wk-gh canonical outbound footer into the PR body at heredoc/template render time (same path as review comments), and run the wk-gh pre-emit gate on the PR body: reject if `DM me your feedback.</sup>` is absent or if the `🦾 Generated with` commit-trailer variant is present.
