---
class: principle
---

# A documented path pattern is executable, not prose

**Rule**

- Sweep 2.87: for every path pattern in the diff containing a glob (`*`, `**`,
  `?`) or a brace expansion, expand it against the working tree and assert a
  non-zero match count.
- Expand brace patterns for real — an existence check on the literal string
  reports a false MISSING and masks the genuine zero-match glob beside it.
- Re-run every structural invariant a doc asserts (patterns expand, relative
  links resolve, documented counts match their source) as an executable check
  after each commit.

**Why**

- Path references in docs are reviewed as prose, never driven as commands. A
  pattern that is syntactically valid and semantically plausible clears a reading
  review; it fails only for the agent who later runs it, and by then the doc
  reads as authoritative, so the agent concludes the files do not exist.
- The catalog already treats a documented command as executable; a documented
  path pattern had no equivalent rule, so a zero-match glob survived two prior
  adversarial rounds.

**Where**

- `references/sweep-catalog-extended.md` → sweep 2.87 (ID listed in the
  `SKILL.md` Step 2 pointer).
