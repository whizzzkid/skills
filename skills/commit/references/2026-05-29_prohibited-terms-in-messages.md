---
class: principle
date: 2026-05-29
skill: wk-commit
severity: high
---

**Rule:** Never name prohibited/internal tokens in commit messages — describe the change by category only.

**Why:** Commit messages are permanent git history. A message that enumerates the tokens being removed re-leaks them even after the files are scrubbed.

**Where:** Landed as `## Prohibited Terms in Commit Messages` HARD RULE (before Post-Push: PR Sync section) and in the Quick Reference table.
