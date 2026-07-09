---
class: one-off
skill: wk-sharpen
date: 2026-07-09
severity: medium
---

- **Scenario:** The Step 5 staged scan greps only `.skillprohibit`, but a second
  pre-commit hook (`scrub-identifiers`, via `.githooks/scrub-staged.sh`) enforces
  a different list — the machine-local, gitignored `.githooks/scrub-denylist.txt`
  plus env tokens (`$EMPLOYER`, `$GITHUB_ORG`) — using perl/PCRE.
- **Symptom:** A `.learned.md` archive carrying an employer literal cleared the
  `.skillprohibit` grep (NONE), so the commit was attempted and the
  `scrub-identifiers` hook rejected it, matching the literal from the local
  denylist. Cost one failed-commit cycle.
- **Fix:** Before committing, also scan staged content against the scrub denylist.
  BSD grep lacks `-P`, so use perl (as the hook does), not `grep -Ef` — the
  denylist entries are PCRE (`(?i)…`) and break ERE:

  ```bash
  git diff --cached -U0 | perl -ne '
    BEGIN{ open F,"<",".githooks/scrub-denylist.txt"; @p=grep{/\S/&&!/^#/} <F> }
    for $r (@p){ chomp $r; print "HIT: $r\n" if /$r/ }'
  ```

- **Why not promoted:** The generalizable rule — treat a NONE as unverified
  because a hook backstop still fires — already lives in Step 5 ("the
  `check-prohibited` hook is the backstop — relying on it costs a failed-commit
  cycle"); that rule predicted this outcome exactly. The only new content is a
  repo-specific perl recipe against a machine-local gitignored file, which is not
  worth inlining into a size-capped SKILL.md.
