---
skill: wk-sharpen
date: 2026-06-22
type: correction
severity: medium
---

The `.skillprohibit` overfit scan must run against the authoritative staged set and a NONE result must be verified, not trusted.

**What happened:** During a batch sharpen, the first overfit scan
(`grep -iEnf .skillprohibit $FILES`, where `$FILES` was a hand-built multi-line
list of paths) returned NONE. The commit was then blocked by the
`check-prohibited` hook, which caught an internal tool codename surviving in a
staged `.learned.md` archive. The scan had silently under-matched the same files
the hook flagged — a false-negative I trusted until the backstop fired.

**Root cause:** The scan input was a hand-assembled file-list variable rather than
the actual staged set, so coverage diverged from what the commit would include. A
NONE result was treated as proof-of-clean instead of as suspect.

**Suggested fix:** In Step 5's mechanical overfit scan, mandate the scan's input
be `git diff --cached --name-only` (the authoritative staged set), not a manually
built list, and treat a NONE result as unverified until confirmed — e.g. sanity
check the grep against a known-positive line. Present-and-correct is not enough;
the scan must demonstrably exercise every file the commit will carry.
