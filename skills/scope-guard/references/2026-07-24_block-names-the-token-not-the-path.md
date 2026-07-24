---
class: principle
skill: wk-scope-guard
date: 2026-07-24
severity: low
---

- **Rule:** A block names the search-root token *as written*, never the logical path.
  The guard does lexical matching and never shell-expands, so one logical path decides
  two ways: `$VAR/…` is not an absolute path and is never compared, while the same path
  pasted as an expanded literal is compared and blocks. Consequences, in order of
  importance: (1) never rewrite a literal root into `$VAR` to clear a block — that is
  the self-authorization the opt-out HARD RULE forbids; (2) before reporting that the
  guard blocks a documented workflow path, drive the hook with the exact command, since
  a block is a property of the spelling, not of the destination.
- **Why:** A field report claimed batch-mode enumeration of an out-of-repo inbox
  tripped the guard, and inferred that *recursion* was the blocked axis. Driving the
  hook directly disproved it: `find "$HOME/<inbox>" -type f` exits 0, the non-recursive
  `ls -A` it proposed as the remedy exits 0 for the same reason (not because it is
  non-recursive), and only a hand-expanded literal exits 2. The report was filed
  against the wrong axis because a workaround that worked was read as evidence for the
  mechanism it was chosen to avoid.
- **Where:** Mechanics section step 2 (single statement of non-expansion; the other two
  sites cross-reference it rather than restating), a third false-block shape, and the
  "nudge, not a security boundary" paragraph carrying the never-exploit prohibition.
  Table and README wording: `resolves outside` → `normalizes outside`, since "resolves"
  is the word that invites the belief that expansion happens.
- **Deliberately not promoted:** the source proposed that batch mode prescribe
  non-recursive listing of known inbox subdirectories instead of a recursive walk. It
  fixes nothing (both forms pass) and is lossy — the destination-resolution step
  supports nested relative paths, which a fixed-depth listing of known subdirectories
  would silently skip. No consumer-skill edit was made.
- **Second time on this axis:** an earlier pass recorded and removed a sibling claim
  ("recursive flag plus unexpanded glob") after the same disproof. Treat any future
  report that names recursion as the blocked axis as disproved-by-default and drive the
  hook before folding.
