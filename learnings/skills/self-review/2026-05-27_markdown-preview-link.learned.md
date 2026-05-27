---
skill: wk-self-review
date: 2026-05-27
type: gap
severity: medium
---

Post rendered-preview link as inline comment when markdown changes are large.

**What happened:** A PR added a 168-line markdown spec. The self-review posted a design-note comment but no link to the GitHub rendered view, leaving reviewers to read raw diff text for a file that renders meaningfully.

**Root cause:** wk-self-review has no instruction to link the rendered preview for large markdown changes.

**Suggested fix:** In Step 2 (Identify Comment-Worthy Changes), add: when a changed file is `.md` and the diff hunk is >50 lines, post an inline comment on the first in-hunk line with the rendered preview URL:

```
https://github.com/<owner>/<repo>/blob/<branch>/<md-file-path>
```

Caption: "Rendered preview — easier to read than the diff for large markdown changes."
