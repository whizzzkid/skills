---
skill: wk-pr-review
date: 2026-11-24
type: correction
severity: medium
verified-against-source: yes
---

Do not post lintable formatting nits (line width, wrapping, whitespace) as review comments.

**What happened:** A `light` review posted a `suggestion:` that a README line exceeded a ~100-column wrap. The repo
has no line-length rule (no editorconfig, markdownlint, or linter config), and the same file already had seven lines
over 100 columns. The "rule" came from the agent's own markdown preferences, not the project. The user called the
comment too shallow: a linter should catch it, not a reviewer.

**Root cause:** The skill does not exclude mechanically checkable style issues from findings. It also does not
require a style finding to cite a rule the project actually configures.

**Suggested fix:** In Phase 4, drop any finding a linter or formatter could catch (line length, wrapping, trailing
whitespace, import order, quote style), whether or not the repo runs one. If the project has no lint rule and the gap
matters, raise it at most once as a change-wide suggestion to add the lint check, never as a per-line comment. Never
apply the agent's own authoring rules (for example a personal markdown width) as review criteria for someone else's
repo.
