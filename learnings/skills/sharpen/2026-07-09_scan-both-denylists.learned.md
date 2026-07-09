---
skill: wk-sharpen
date: 2026-07-09
type: gap
severity: medium
---

The Step 5 overfit pre-scan greps only `.skillprohibit`, but the `scrub-identifiers` pre-commit hook enforces a *separate* denylist (`.githooks/scrub-denylist.txt`) — so a term present only in the hook's list passes the skill's scan yet blocks the commit.

**What happened:** A term-handling `.learned.md` archive carried an employer literal as its example token. The skill's staged scan against `.skillprohibit` returned NONE (that literal is not in `.skillprohibit`), so the commit was attempted — and the `scrub-identifiers` hook rejected it, matching the same literal from `.githooks/scrub-denylist.txt`. Cost one failed-commit cycle to discover and scrub.

**Root cause:** Step 5 treats `.skillprohibit` as the single authoritative term list. Two independent hooks scan two different lists: `check-prohibited` reads `.skillprohibit`; `scrub-identifiers` reads `.githooks/scrub-denylist.txt` (which holds employer/org literals absent from `.skillprohibit`). Scanning only one leaves the other as an unexercised commit-time backstop.

**Suggested fix:** In the Step 5 staged scan, grep every staged file against BOTH `.skillprohibit` and `.githooks/scrub-denylist.txt` (union the pattern files) before presenting the diff and before commit. A NONE result is only trustworthy when it clears both lists.
