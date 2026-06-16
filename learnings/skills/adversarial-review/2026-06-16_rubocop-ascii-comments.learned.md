---
skill: wk-adversarial-review
date: 2026-06-16
type: gap
severity: medium
---

Ruby diffs with non-ASCII characters in comments (em-dash, curly quotes, etc.) fail RuboCop Style/AsciiComments.

**What happened:** A Ruby comment used an em-dash (`—`) which passed local review but failed CI's RuboCop gate with `Style/AsciiComments: Use only ascii symbols in comments.`

**Root cause:** Mechanical sweep 2.4 checks assertive claims in comments but does not audit the character encoding of new/modified comment text against the `Style/AsciiComments` cop.

**Suggested fix:** Add a sweep to the Ruby diff path: grep new `+` comment lines for non-ASCII characters (`[^\x00-\x7F]`) and flag them as a blocker when the repo runs RuboCop with `Style/AsciiComments` enabled (check `.rubocop.yml` for the cop's `Enabled:` state).
