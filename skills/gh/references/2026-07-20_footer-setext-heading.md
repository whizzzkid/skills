---
class: principle
---

**Rule** — The outbound footer block must begin with a **blank line** before
`---` — build it as `"\n\n---\n<sup>…"` (two newlines). A pre-emit gate rejects any
body where a non-blank line is immediately followed by `---`.

**Why** — In GitHub-Flavored Markdown, a non-blank line immediately followed by
`---` on the next line is a setext H2 heading (`---` underlines the preceding
line), not a horizontal rule — the last paragraph renders large/bold. A single
`\n` is a line break, not a blank line, so `"\n---"` silently triggers it.

**Where** — Step 4 footer placement rules + pre-emit gate. Guard must be portable:
BSD/macOS `grep` has no `-P`; use `awk 'prev!="" && $0=="---"{f=1} {prev=$0} END{exit f}'`.
