---
skill: wk-pr
date: 2026-07-10
type: correction
severity: low
---

PR description footer must sit below a `---` rule and be wrapped in `<sup>`.

**What happened:** The PR body was created ending in a bare footer line
(`🦾 Generated with [wk-skills](https://github.com/whizzzkid/skills) and multiple models.`)
with no separator and no `<sup>` wrapper. The user flagged it: the footer needs a
`---` horizontal rule before it and the annotation wrapped in `<sup>...</sup>`,
matching the review-comment footer style.

**Root cause:** The PR-body footer convention was treated as a bare trailing
line. The skill documents the footer text but not its required formatting
(leading `---` rule + `<sup>` wrapper), so it rendered as ordinary body text
instead of a small-print footer visually separated from the description.

**Suggested fix:** Document the exact PR-description footer format in `wk-pr`: the
body must end with a `---` line followed by
`<sup>🦾 Generated with [wk-skills](https://github.com/whizzzkid/skills) and multiple models.</sup>`.
A footer without the `---` separator and `<sup>` wrapper is incorrect.
