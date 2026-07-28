---
class: principle
---

**Rule:** At distill time (Step 3), run the source learning/memory's core subject
term through `.skillprohibit` — before byte-budgeting or drafting. On match, the
lesson cannot land in the public skill repo: route it to the user's private
`CLAUDE.md`, mark the source distilled, and skip the fold entirely.

**Direction is part of the rule.** The denylist is the *pattern* operand, never the
haystack. "Grep X against Y" does not fix which operand supplies the patterns, and the
wrong reading fails open — see [`staged-path-scan.md`](staged-path-scan.md).

**Strip the pattern file's comments and blanks before `-f`** — `grep` has no comment
syntax, so every line of the file is a pattern. The owning hooks strip them
(`grep -vE '^[[:space:]]*(#|$)'`) and a hand-roll that does not will fail **dirty**:

```bash
printf '%s\n' "$term" \
  | command grep -inEf <(command grep -vE '^[[:space:]]*(#|$)' .skillprohibit)
```

- A bare `#` line matches any subject containing `#`; a blank line matches everything.
- Drop `-q` in favour of `-in` — `-q` suppresses the matched pattern, which is the only
  evidence that separates a real hit from a comment-line artefact.

**Why:** The Step 5 mechanical overfit scan greps the *drafted edit text* and runs
late — after distill, classify, byte-budget, and draft. A lesson *about* an internal
or prohibited tool can only ever produce edit text that names the tool, so the
prohibited-term collision is determinable before any drafting. Deferring the check to
Step 5 means the full fold + any structural byte-reclaim is built and then reverted.

**Where:** `wk-sharpen` Step 3 (Distill the Lesson), as a HARD RULE preceding the
full-read and classification rules. Complements the Step 5 staged-set scan
(`grep -iEnf .skillprohibit $(git diff --cached --name-only)`), which remains the
backstop for terms that only surface in the edit text.
