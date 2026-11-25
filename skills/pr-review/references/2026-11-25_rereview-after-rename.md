---
class: principle
---

# Re-review after a rename: match threads by content through an old→new path map

- **Rule** — When the re-review delta renames files or directories, build an old→new path map from the rename
  entries, hand it to every verifier, and match each prior thread by content at its new path, never by its recorded
  `path` + `line`. A body naming an absent file is `stale (superseded)` only when no rename maps it.
- **Why** — Fix commits renamed a check, its reference folder, and its corpus folder; every prior thread's path and
  line went stale. Verifiers had to be told the map ad hoc and search by content. Line matching against pre-rename
  coordinates misclassifies real fixes as stale and real misses as fixed.
- **Where** — `SKILL.md` Phase 2 "Stale when" bullet; [`re-review-follow-up.md`](re-review-follow-up.md) "Verify each
  fixed reply" ("Renamed paths").

## Not folded

- **Library-wide dependent check for re-ruled rules** — `already-covered`: `SKILL.md` Phase 2 "Re-review" bullet
  ("grep each "fixed" finding's pattern file- and sibling-wide, and dependents for fix-made contradictions") and
  `re-review-follow-up.md` "Pattern-level, not quoted-line" + "Fix-induced contradictions" bullets, installed the day
  before the report. The report lists the contradictions the delta created (sibling cards, adjacent check clauses,
  stale corpus counts), so the rule fired; no escalation.
- **Shareable root message → separate markdown file** — `one-off`: consistent with the installed body HARD RULE
  (verdict line plus footer only); a user-requested shareable write-up is a separate artifact, never review-body text.
