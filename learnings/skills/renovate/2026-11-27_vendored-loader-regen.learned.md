---
skill: wk-renovate
date: 2026-11-27
type: gap
severity: medium
verified-against-source: yes
---

A lockfile-only bump can be red because the gem ships a vendored copy that its own validator compares to the installed gem.

**What happened:** One Dependabot PR's CI failed because the repo vendors a file from the bumped gem (loaded by the CI
pipeline before bundling), and the gem's `validate` command rejects a vendored copy that differs from the installed
version. The fix was running the gem's `init` command to regenerate the vendored file and committing it with the bump.

**Root cause:** Dependabot only rewrites the lockfile; it never runs a gem's regeneration step. Confirmed from the
red CI job log and by running `validate` before and after `init`.

**Suggested fix:** In Step 4, for each bumped gem, grep the repo for vendored copies (`vendor/<gem>` dirs, files whose
header names the gem) and check the original PR's failing CI log first. A red Dependabot PR usually says exactly what
regeneration it needs. Also: the user may merge the combined PR (auto-merge) before mark-ready, so run the
major-version adversarial review before pushing, not after.
