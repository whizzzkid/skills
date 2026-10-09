---
class: principle
---

# Never bypass hooks — env-var disables are `--no-verify`

**Rule**

- Every hook-bypass mechanism is the same forbidden act: `--no-verify`, `LEFTHOOK=0`, `HUSKY=0`, `SKIP=<hook>`, a
  `core.hooksPath` override.
- One failing gate is a requirement to satisfy (co-stage the file it demands), never a reason to disable the suite.
- Tree holds untracked files the commit does not own → stage explicit file paths, never a directory or `-A`.

**Why**

- The prior rule named only the `--no-verify` flag, so an env-var disable was not recognized as the same bypass.
  Disabling the whole suite to clear one gate let several commits skip every other gate; re-enabled hooks immediately
  caught a dropped reference pointer and corrupted frontmatter that had shipped.
- Directory-level staging pulled a pre-existing untracked file into a commit. The staged-set check catches this only if
  it runs; explicit-path staging prevents it.

**Where**

`skills/commit/SKILL.md` → Hook and verify rules (HARD RULE) and Staging Discipline.
