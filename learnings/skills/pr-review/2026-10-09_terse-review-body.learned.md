---
skill: wk-pr-review
date: 2026-10-09
type: correction
severity: medium
verified-against-source: n/a
---

The review body is the verdict line only. Cut everything after it before posting.

**What happened:** The drafted body was "LGTM, two minor questions." followed by three more sentences:
how deep the pass went ("This was a shallow pass"), a summary of what looked fine ("the gate, nudge
routing, and check-run/summary text all look consistent"), and a note about a duplicate bot thread.
{user} edited it down to just `LGTM, two minor questions.` plus the footer before submitting. The
inline comments went out unchanged.

**Root cause:** The skill's "LGTM is one line" rule only covers reviews with no concerns. When there
were inline comments, the agent treated the body as room for summary and context. The user wants the
one-line form whenever the inline comments carry the substance.

**Suggested fix:** In Phase 5 "Compose the review body":
- Default to one verdict line whenever every finding has an inline anchor, not only for a clean LGTM.
- Add a second line only for a change-wide concern that has no inline anchor.
- Never put these in the body: how deep the review went (shallow/deep/what was skipped), a list of
  what looked fine, or notes about bot or duplicate threads. Mention review depth to the user in the
  terminal instead.
- Before posting, run a gate: if the body has more than one sentence before the footer, each extra
  sentence must name an un-anchored concern, otherwise cut it.
