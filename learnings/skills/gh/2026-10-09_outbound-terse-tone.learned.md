---
skill: wk-gh
date: 2026-10-09
type: correction
severity: medium
verified-against-source: yes
---

Top-level GitHub bodies posted for the user must be terse: state the point, add nothing else.

**What happened:** The agent drafted a top-level review body with a verdict, a pointer to an inline thread, and
an evaluative sentence ("the rest ... looks right"). Before submitting, the user cut it to the verdict alone. The
user's stated preference is that top-level (parent) comments posted for them are terse and to the point.

**Root cause:** wk-gh's Step 3 / Step 4 define the canonical write surface and the footer, but say nothing about
tone or length. Each calling skill sets its own verbosity, and their templates lean wordy. No shared rule exists
for every outbound body.

**Suggested fix:** Add a "Tone and length" rule to Step 3 that applies to every write surface: PR/issue
conversation comments, review bodies, and replies.
- First line is the point (verdict, answer, or action). Nothing comes before it.
- No pointers to content GitHub already shows next to the body (inline threads, the diff, CI).
- No evaluative filler ("looks right", "solid", "nice work"), and no recap of what was checked.
- Top-level/parent bodies default to one line. Use at most two short sentences, and only when a point has
  nowhere else to live.
- Inline comments may carry evidence and a fix, but never exceed what the single finding needs.
- Callers (wk-pr-review, wk-self-review, wk-pr-resolve) inherit this rule; their own templates may be stricter,
  never looser.
