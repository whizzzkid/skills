---
class: principle
---

- **Rule:** Escape `#` in Markdown link text as `\#` and use full PR/issue titles: `[repo\#N: commit-style title](url)`. Never bare `repo#N`.
- **Why:** SilverBullet runs an inline hashtag parser over link text after CommonMark; an unescaped `#word`/`#N` inside `[...]` is tokenized as a tag and corrupts the enclosing link node.
- **Where:** "HARD RULE — SilverBullet markdown formatting"; every `{repo}\#{N}: {title}` template in the live.md and snapshot bodies.
