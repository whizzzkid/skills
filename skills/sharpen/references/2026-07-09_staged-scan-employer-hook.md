---
skill: wk-sharpen
class: principle
---

**Rule** — In the Step 5 staged scan, grep against BOTH term lists, not only
`.skillprohibit`. The employer/org name (`$EMPLOYER`/`$GITHUB_ORG`) and repo
denylist are enforced by a SEPARATE hook, `scrub-staged.sh` (lefthook
`scrub-identifiers`). Run it explicitly on staged files before committing:

```bash
bash .githooks/scrub-staged.sh
```

Pre-scrub every renamed `.learned.md`/retro archive proactively — a rename ships
the source learning verbatim, which routinely names the employer.

**Why** — This is a re-violation: the "scrub archives" rule existed but the
Step 5 command block only ran `.skillprohibit`, so an archive carrying the raw
employer name passed Step 5 and then aborted the commit at `scrub-staged.sh` —
a wasted failed-commit cycle. `.skillprohibit` and the employer denylist are
different files behind different hooks; a clean `.skillprohibit` scan is not a
clean employer scan.

**Where** — wk-sharpen Step 5 mechanical overfit scan; rule escalated to
**Important** on this re-violation.
