---
class: principle
---

**Rule:** A Mermaid `click` directive on GitHub navigates only when its `href`
target is an absolute URL. A relative path (`./x`, `../x`) or bare anchor
(`#x`) renders as a real, clickable link but resolves against the sandboxed
mermaid iframe origin — not the repo — so it 404s. A `click ... call <fn>` JS
callback is stripped entirely.

**Why:** Earlier skill guidance claimed all `click` directives "do nothing /
are stripped." That is only true for the `call` (JS) form. The `href` form
*does* render and navigate, which is the trap: an agent adds a relative
`click ... href "./foo/README.md"`, it looks wired up locally (the file
exists), and it silently 404s for every reader on GitHub. The failure is
invisible to local file-existence checks and to link checkers like lychee,
which skip fenced code blocks and never see the click target at all.

**Where:** wk-mermaid Step 4 (escalated to HARD RULE), Step 5 grep pattern,
Common Mistakes, Quick Reference. Enforced mechanically by
`.githooks/check-mermaid-links.sh`, which blocks relative/anchor click targets
and canonical blob URLs that do not resolve to a repo file. Prefer a markdown
link beside the diagram for navigation; reserve `click` for when interactivity
is genuinely wanted, always with an absolute URL.
