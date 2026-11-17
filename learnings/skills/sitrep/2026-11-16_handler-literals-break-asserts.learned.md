---
skill: wk-sitrep
date: 2026-11-16
type: gap
severity: low
verified-against-source: yes
---

Post-write assertions on span markup must not count raw `data-t=` or a literal backslash-n across whole lines.

**What happened:** The inline validator asserted at most one `data-t=` per line and no literal `\n` text. Both fired on valid pages: the canonical toggle handler contains the string `'data-t='` and the standup copy block contains `join('\n')`.

**Root cause:** The assertions matched substrings that the canonical recipes themselves emit; the checks were written against the attribute, not the handler body.

**Suggested fix:** State the uniqueness check as the attribute form with a quote and `t` prefix, and exempt the copy-block line from the stray-`\n` grep.
