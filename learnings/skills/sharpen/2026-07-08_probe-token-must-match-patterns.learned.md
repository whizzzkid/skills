---
skill: wk-sharpen
date: 2026-07-08
type: gap
severity: low
---

The grep-fires probe used a guessed generic token not present in the pattern file, producing a false PROBE FAILED and a wasted cycle.

**What happened:** To prove the NONE prohibited-scan result was real (not a broken grep), I ran the probe with invented tokens (a generic employer-style name and a `<KEY>`-shaped ticket string). Neither is in `.skillprohibit`, so grep correctly matched nothing — but that reads as "grep is broken," forcing a second probe with a real pattern token before the scan could be trusted.

**Root cause:** Step 5 says "prove grep fires by feeding it a string the patterns match" but does not stress the probe token must be **derived from `.skillprohibit`'s actual lines**, not a plausible-looking guess. A generic employer/ticket guess will not match a machine-local, codename-based pattern list.

**Suggested fix:** In the grep-fires-probe instruction, require reading a real pattern line from `.skillprohibit` first (expand a regex line, e.g. `a[-_]?b` → `a-b`, or copy a literal like a codename), then feed that exact token. Never guess the probe token.
