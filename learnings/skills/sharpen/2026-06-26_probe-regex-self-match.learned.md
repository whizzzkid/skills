---
skill: wk-sharpen
date: 2026-06-26
type: surprise
severity: low
---

A `.skillprohibit` line used as literal probe input won't self-match when it contains regex metacharacters.

**What happened:** Applying the just-folded "source the known-positive probe from `.skillprohibit` itself" rule, I echoed the file's first non-comment line (a pattern of shape `a[-_]?b`) through `grep -iEf .skillprohibit`. The probe did NOT fire — the literal string `a[-_]?b` does not match the regex `a[-_]?b` (the `[`, `]`, `?` are metacharacters in the pattern but literal in the input). The real staged-file scan fired correctly on the actual `a-b` text moments later, so grep was functional the whole time.

**Root cause:** `.skillprohibit` patterns are regexes, not plain literals. Feeding a regex pattern back as grep *input* tests literal-string equality against the regex, which fails whenever the pattern uses `[]`, `?`, `*`, `+`, etc. The folded rule assumes pattern lines double as known-positive sample text — true only for plain-literal lines.

**Suggested fix:** When sourcing the probe sample, pick a plain-literal line (no regex metacharacters) from `.skillprohibit`, or synthesize a matching string from the pattern (e.g. expand `a[-_]?b` → `a-b`). Better: treat a real hit in the staged-file scan as the functional proof and skip the synthetic probe entirely when the scan already returned a match.
