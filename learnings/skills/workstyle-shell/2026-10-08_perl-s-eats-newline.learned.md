---
skill: wk-workstyle-shell
date: 2026-10-08
type: surprise
severity: medium
verified-against-source: yes
---

`\s*$` in `perl -pi` substitutions consumes the line's newline.

**What happened:** A version-bump one-liner `s/^(\s+version:\s*)"..."\s*$/.../` joined each edited line with the next YAML key, corrupting frontmatter.

**Root cause:** Under `-p`, `$_` includes the trailing `\n`; `\s` matches it, so the replacement drops the newline.

**Suggested fix:** In line-mode perl, use `[ \t]*$` (horizontal whitespace) instead of `\s*$`; diff structured files (frontmatter) after any bulk regex edit.
