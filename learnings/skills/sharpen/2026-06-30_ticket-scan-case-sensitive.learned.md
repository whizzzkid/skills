---
skill: wk-sharpen
date: 2026-06-30
type: gap
severity: low
---

The overfit ticket-shape scan must run case-sensitive — `grep -i` floods false positives.

**What happened:** During the Step 5 overfit scan I ran the ticket regex `[A-Z][A-Z0-9]+-[0-9]+` with `grep -iEnH`. The `-i` made it match CamelCase-plus-number tokens like `Session-2` and `Step-5`, producing alarming false hits that needed a second case-sensitive pass to clear.

**Root cause:** The `check-ticket-refs` hook matches on uppercase shape (real board keys are `[A-Z][A-Z0-9]+-\d+`). Adding `-i` to the manual probe widens it to any `Word-Number`, which is noise, not a ticket.

**Suggested fix:** In the mechanical overfit scan, specify the ticket-shape grep is case-sensitive (no `-i`) so the manual probe matches the hook's actual behavior. Note that `-i` yields false positives from CamelCase-number tokens.
