---
skill: wk-gh
date: 2026-08-04
type: surprise
severity: low
verified-against-source: yes
---

Pass an explicit PR argument to `gh pr view --web` when also passing `--repo`.

**What happened:** `gh pr view --repo {owner}/{repo} --web` failed with
`argument required when using the --repo flag` even though the command ran inside the repository.

**Root cause:** This `gh` version requires a positional pull request when repository selection is explicit.

**Suggested fix:** Teach the GitHub skill to use
`gh pr view <number-or-url> --repo {owner}/{repo} --web`, or omit `--repo` when relying on
current-branch inference.
