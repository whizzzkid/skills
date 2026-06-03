---
skill: wk-sitrep
date: 2026-06-03
type: correction
severity: high
---

Escape `#` in Markdown link text with `\#` and include full PR titles in `repo\#N: title` format.

**What happened:** SilverBullet extends CommonMark with inline hashtag parsing. A `#word` sequence anywhere in paragraph text — including inside Markdown link text like `[{repo}#NNN](url)` — gets parsed as a tag, which corrupts the link. Observed: `[{repo}#NNN](url)` was mangled into a stray `[#NNN](url)` tag node prepended to the link by SilverBullet's editor.

**Root cause:** SilverBullet's hashtag parser runs over inline content after CommonMark parsing and does not exempt link text. Any `#\d+` or `#word` inside `[...]` is treated as a tag token, breaking the enclosing link node.

**Suggested fix — two rules to encode in wk-sitrep:**

1. **Always escape `#` in Markdown link text.** Use `\#` (CommonMark escape) so the character renders as `#` but does not trigger the hashtag parser: `[repo\#NNN: title](url)`.

2. **Always include the full PR/issue title in link text**, formatted as `repo\#N: commit-style title`. This makes links self-documenting in the rendered page and in the raw markdown. Never use bare `repo#N` as the full link text — it's both fragile (hashtag breakage) and uninformative.

**Pattern:**
```markdown
[{repo}\#NNN: docs(specs): RFC title](https://github.com/.../pull/{n})
[{repo}\#NNN: feat(scope): change summary](https://github.com/.../pull/{n})
```
