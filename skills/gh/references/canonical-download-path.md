---
class: principle
---

# Canonical download path

For artifact download paths, see `skills/buildkite/SKILL.md` — the pattern is
identical (`/tmp/agent/<tool>/<resource>/...`). The `gh`-specific root is
`/tmp/agent/gh/<owner>/<repo>/<resource_type>/<resource_id>/<filename>`.

Apply `--owner=$GITHUB_ORG` filtering to all `gh search` and `gh api
notifications` calls when writing artifacts to ensure the path namespace
stays org-scoped.
