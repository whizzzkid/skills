---
skill: wk:pr-review
date: 2026-04-27
type: pattern
severity: medium
---

Playground experimentation under macOS `/bin/bash` (3.2) caught a bash 4+ portability bug (`${var,,}`) that 3 rounds of Copilot review and the author's own validation missed.

**What happened:** While running adversarial edge cases against `resolve_ci_pipeline_slug`, the playground script invoked the function with the system bash and immediately exposed `bad substitution` errors on `${repo_name,,}`. Confirmed via `bats test/...resolve-ci-pipeline.bats` under `/bin/bash` (20/22 fail) vs homebrew bash 5 (all pass).

**Root cause:** Reviewers (and the author) all ran tests with bash 4+ on PATH, so the bash 3.2 path was never exercised. Static review can't catch shell-version-specific syntax — runtime execution under the older interpreter does.

**Suggested fix:** When reviewing shell scripts in projects that target both Linux CI and macOS dev workstations, the playground should explicitly run a bats / sourcing pass under `/bin/bash` (the bash 3.2 macOS default) in addition to whatever's first on PATH. Add this as a default check whenever shell files appear in the diff. Idioms to grep for: `${var,,}`, `${var^^}`, `declare -A`, `mapfile`, `readarray`, `${var^}`, `${var,}`.
