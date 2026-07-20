---
skill: wk-gh
date: 2026-07-20
type: correction
severity: medium
---

The outbound footer's `---` must be preceded by a blank line, or Markdown renders the last paragraph as a giant H2 heading.

**What happened:** GitHub review body + inline comments joined the last paragraph directly to the footer as `text\n---\n<sup>…`. In GitHub-Flavored Markdown, `text` on one line immediately followed by `---` on the next is a **setext H2 heading** (`---` underlines the preceding line), not a horizontal rule. Every comment's final paragraph rendered large/bold. The user noticed before the review was submitted.

**Root cause:** The footer string was built with a single leading newline (`"\n---\n<sup>…"`), so there was no blank line between the body's last line and the `---`. The skill's Step 4 rule already says "Separate from prior content with a blank line above the `---`," but building the footer as `"\n---"` and appending it with `"$BODY$FOOTER"` silently violates it — one `\n` is a line break, not a blank line.

**Suggested fix:** The canonical footer block must begin with a **blank line** before `---` — i.e. build it as `"\n\n---\n<sup>…"` (two newlines) so the rendered output is `…text␊␊---␊<sup>…`. Add a pre-emit gate that rejects any body where a non-blank line is immediately followed by `---` (setext-heading pattern). NOTE: the guard must be portable — BSD/macOS `grep` has no `-P`; use `awk` or a `perl -0777` check, e.g. `awk 'prev!="" && $0=="---"{f=1} {prev=$0} END{exit f}'`, not `grep -qzP`.
