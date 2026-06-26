---
skill: wk-sharpen
date: 2026-06-26
type: gap
severity: low
---

The prohibited-term grep sanity-check must use a term actually in the list, not a guessed one.

**What happened:** Running the Step 5 known-positive sanity check, I piped a guessed
employer/codename string through `grep -iEf .skillprohibit`. It did not fire —
the term was not in the pattern file (that token is handled by a separate
scrub-identifiers hook, not the prohibited list). The grep printed a false "did
not fire" warning even though the grep was fully functional (it correctly caught
a real prohibited codename in the staged set moments later).

**Root cause:** The sanity-check rule says "sanity-check the grep fires against a
known-positive line" but does not say where to source the known-positive. Guessing
a term risks picking one the file does not list, producing a misleading
"grep broken" signal.

**Suggested fix:** Sanity-check by echoing a literal pattern read FROM
`.skillprohibit` itself (e.g. the first non-comment line), not an invented term.
That guarantees the probe matches what the grep actually scans for.
