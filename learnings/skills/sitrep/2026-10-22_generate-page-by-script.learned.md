---
skill: wk-sitrep
date: 2026-10-22
type: pattern
severity: low
verified-against-source: n/a
---

Compile the live page with a small generator script instead of hand-writing every span.

**What happened:** A 65-item page with a long inline onclick handler on every checkbox was produced by a script that
numbers `data-t` sequentially, escapes `#` in text, and reuses the copy-button markup lifted from the previous page. The
render check passed first time (3 columns, contained items, 3 standup branches), and the auto-review step could patch the
placeholder line afterwards by reusing the handler from an existing checkbox.

**Root cause:** Hand-typing the handler and sequential IDs is slow and error-prone; the skill does not suggest a
generator.

**Suggested fix:** Mention in Stage 4 that a throwaway script (kept in the scratchpad, never the repo) may emit the
spans, and that a missing-tool agent domain (here, notes) should be replayed in the main session before declaring a gap.
