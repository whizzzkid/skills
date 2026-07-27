---
skill: wk-sharpen
date: 2026-07-25
type: gap
severity: medium
verified-against-source: yes
---

A positive control built from a regex's own source text can never match, so the proof step reports "matcher is broken" when the matcher is fine.

**What happened:** Step 5 requires proving a hand-rolled staged-path scan actually fires
before a `NONE` result may be trusted. The denylist holds **regexes**, not literals
(shapes like `foo[-_]?bar`, `\bbaz\b`, `qux-[0-9]`). The canary subject was constructed by
reading the first pattern and pasting it verbatim into a filename, producing a subject
containing the literal characters `foo[-_]?bar`. The pattern `foo[-_]?bar` does not match
that string — `[-_]?` in the pattern means "optional `-` or `_`", while in the subject it
is five literal characters. The control returned no match, printing a "matcher is broken"
verdict against a matcher that was working correctly.

The real scan's `NONE` was therefore left unverified, and the natural next move — swap or
abandon the comparison primitive — would have been taken on false evidence. Re-running the
control with a subject the pattern actually matches (`foo-bar`) proved the matcher live,
and the real scan's `NONE` was then genuine and independently corroborated by the owning
hook passing.

**Root cause:** The skill mandates *that* the grep be proven to fire but not *how* to build
the subject that proves it. Pattern source and matching subject are different strings for
any pattern containing metacharacters, and a denylist of regexes is exactly the case where
copying the pattern as the canary is the obvious wrong move. Confirmed by driving the
matcher directly against both subjects.

**Suggested fix:** State how to construct the canary: expand the pattern to a concrete
matching literal (resolve `[...]?` / `\b` / quantifiers) or hardcode a known-matching
subject — never paste pattern source as the subject. Add the diagnostic ordering: a FAILED
positive control indicts the **control** before the matcher, so fix the canary and re-run
before concluding anything about the primitive; never let a failed control justify swapping
the primitive. Note that a canary must stay in-memory when the pattern list is a denylist —
writing it to a staged path would trip the very hook being tested.
