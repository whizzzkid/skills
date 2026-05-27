---
skill: wk-pr
date: 2026-05-27
type: gap
severity: medium
---

Link GitHub rendered preview when PR introduces markdown file changes.

**What happened:** PR #NNN added a new markdown spec file. The PR description and self-review had no link to the rendered preview, making it harder for reviewers to read the formatted output instead of the raw diff.

**Root cause:** wk-pr and wk-self-review have no instruction to surface a rendered-preview link when markdown files are in the diff.

**Suggested fix:** In wk-pr Step 2 (Create Draft PR), after detecting `.md` files in the diff, append a "Preview" bullet to the PR body for each changed markdown file:

```
- [Rendered preview](https://github.com/{owner}/{repo}/blob/{branch}/{path})
```

Format: `https://github.com/<owner>/<repo>/blob/<branch>/<md-file-path>`

In wk-self-review Step 2, when a markdown file is large enough that the diff is hard to read (heuristic: >50 lines added), post an inline comment on the first changed line linking the rendered preview so reviewers can open it alongside the diff.
