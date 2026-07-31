---
skill: wk-gh
date: 2026-07-31
type: gap
severity: low
verified-against-source: yes
---

Use standalone `jq` when a GitHub CLI projection needs variables.

**What happened:** A live pull-request rollup query passed `--arg` after `gh pr view --jq`, and the
GitHub CLI rejected the extra arguments before evaluating the expression.

**Root cause:** The GitHub CLI's `--jq` option accepts only one expression; it does not expose the
standalone `jq` command's argument-binding flags.

**Suggested fix:** Document that variable-dependent projections must pipe raw `--json` output into
standalone `jq --arg`, while constant projections may continue using `gh --jq` directly.
