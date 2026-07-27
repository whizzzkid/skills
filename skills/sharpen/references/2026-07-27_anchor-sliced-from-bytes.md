---
class: principle
skill: wk-sharpen
date: 2026-07-27
severity: medium
---

# An exact-match edit anchor is sliced from the file's bytes, never a rendering

**Rule** — Any `old_string` / exact-match anchor must come from the same bytes that
located the edit. Never transcribe one out of a rendered tool result. A read that is
refused, stale, or returns no content is retried as a **narrow ranged re-read** — not
substituted with a whole-file shell dump, which is another rendering.

**Why** — A rendering can be lossy with no marker distinguishing an abridged line from a
faithful one, and the abridged prose stays grammatical enough to read as real (whole words
dropped mid-sentence). The anchor then either fails the edit or — worse — matches a
*different* span and edits the wrong text silently.

**Coverage before this fold** — `partial`. Two adjacent rules existed and neither reached
the anchor:

- [`byte-budget.md`](byte-budget.md) already says to slice `old` out of the file and never
  retype it, but scopes that to **pricing a reclaim**. A mispriced budget is off by bytes;
  a mis-anchored edit corrupts content.
- The escalation section's landing-check clause already says a landing check reads worktree
  bytes, never a tool's rendering — scoped to **verification needles**, not edits.

The failure shape is identical across all three; only the edit anchor was ungoverned.

**Verified against source** — reproduced in this run, not taken from the report. The
distilling run's own full-file `Read` of the target `SKILL.md` came back with `<<ccr:…>>`
compression markers standing in for ~20 spans, and a `sed` of a reference file came back
with articles dropped and lines joined. Every anchor used for this run's six edits was
therefore taken from narrow ranged re-reads, which returned exact bytes; all six matched
first try. That is the control: the same edits composed from the compressed rendering had
no matchable text to copy.

**Classification** — `principle`. Generalizes to any exact-match operation whose literal
crosses a display layer.

**Escalation** — None. No rule governed where an *edit* anchor's text comes from; the two
neighbouring rules fired correctly on their own questions (pricing, landing checks). Gap,
not re-violation.

**Where** — `SKILL.md` → Step 2, folded as a tightening of the existing partial-read
bullet rather than a new one. That bullet is the single place stating what a read must
deliver before an edit is allowed, so the byte-vs-rendering question belongs to the same
reader at the same moment; splitting it out would state one read discipline at two sites.

**Arithmetic** — Addition **+185 B** (82 → 267). Shared reclaim and ratio recorded in
[`2026-07-27_flipper-outranks-peers.md`](2026-07-27_flipper-outranks-peers.md), which
landed in the same measured pass.
