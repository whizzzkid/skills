---
skill: wk-sharpen
date: 2026-07-09
type: gap
severity: medium
---

Step 5 staged scan greps only `.skillprohibit`, but the employer/org name in a renamed `.learned.md` is caught by a DIFFERENT hook with a DIFFERENT list.

**What happened:** A `.learned.md` archive being committed carried the raw employer name ("...RuboCop/$EMPLOYER cops...") from the original learning. The `.skillprohibit` scan (Step 5) passed clean, so the commit was attempted — then `scrub-staged.sh` (lefthook `scrub-identifiers`) aborted it, matching `(?i)$EMPLOYER` against the staged diff. Cost a failed-commit cycle and a scrub-then-recommit.

**Root cause:** Step 5's overfit scan runs `grep -iEf .skillprohibit`, but the employer/`$GITHUB_ORG` denylist lives in `.githooks/scrub-denylist.txt` + resolved `$EMPLOYER`/`$GITHUB_ORG` env vars, enforced by a separate hook. A `.learned.md` rename ships the source learning verbatim, which routinely names the employer.

**Suggested fix:** In Step 5, after the `.skillprohibit` scan, also run `bash .githooks/scrub-staged.sh` (or the equivalent `(?i)$EMPLOYER`/`$GITHUB_ORG` + denylist grep) against staged files — especially every renamed `.learned.md`/retro archive — before attempting the commit. Pre-scrub the archive proactively rather than discovering it at the commit gate.
