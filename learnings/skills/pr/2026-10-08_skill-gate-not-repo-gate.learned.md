---
skill: wk-pr
date: 2026-10-08
type: correction
severity: medium
verified-against-source: n/a
---

Do not present a skill-internal merge gate as a requirement of the repo.

**What happened:** After marking a PR ready, the agent said the adversarial review "is needed before merge". The {user} said this was false. The repo and its branch protection do not require it.

**Root cause:** The skill says "review gates merge". The agent reported this skill rule as if the repo enforces it.

**Suggested fix:** When you report merge gates, put repo-enforced gates (required checks, branch protection, CODEOWNERS) separate from skill conventions. If you mention a skill convention, label it as optional or as a skill convention. Do not call it a merge blocker.
