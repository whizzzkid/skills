---
class: principle
---

**Rule:** At distill time (Step 3), run the source learning/memory's core subject
term through `.skillprohibit` — before byte-budgeting or drafting. On match, the
lesson cannot land in the public skill repo: route it to the user's private
`CLAUDE.md`, mark the source distilled, and skip the fold entirely.

**Direction is part of the rule.** The denylist is the *pattern* operand, never the
haystack: `printf '%s\n' "$term" | command grep -qiEf .skillprohibit`. "Grep X against
Y" does not fix which operand supplies the patterns, and the wrong reading fails open —
see [`staged-path-scan.md`](staged-path-scan.md).

**Why:** The Step 5 mechanical overfit scan greps the *drafted edit text* and runs
late — after distill, classify, byte-budget, and draft. A lesson *about* an internal
or prohibited tool can only ever produce edit text that names the tool, so the
prohibited-term collision is determinable before any drafting. Deferring the check to
Step 5 means the full fold + any structural byte-reclaim is built and then reverted.

**Where:** `wk-sharpen` Step 3 (Distill the Lesson), as a HARD RULE preceding the
full-read and classification rules. Complements the Step 5 staged-set scan
(`grep -iEnf .skillprohibit $(git diff --cached --name-only)`), which remains the
backstop for terms that only surface in the edit text.
