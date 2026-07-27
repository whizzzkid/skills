---
class: principle
skill: wk-scope-guard
date: 2026-07-24
severity: medium
---

# Classify a search's argv by argument role, not by token shape

- **Rule:** A lexical path-scope guard must scope-check only the **path operands**
  of an in-scope search, resolved under that tool's own grammar — not every
  absolute-looking token in the payload. A grep-family tool's first positional is
  the *pattern* (absent when `-e`/`-f` supplies it); `find`/`fd` paths precede the
  first expression flag. Classify per command segment, so an unrelated segment's
  arguments are never charged as search roots.
- **Why:** Path-like tokens were classified by shape, not role, so text appearing
  *as data to match* was indistinguishable from a directory *to search*. Two
  in-scope commands false-blocked: a scrub check grepping repo-relative files FOR
  absolute-path shapes (the shapes are the pattern), and a compound pairing one
  search with an unrelated command holding an out-of-repo path. Neither has an
  out-of-scope root. This is a correctness fix, not a relaxation — a genuine
  out-of-repo root is still a path operand and still blocks.
- **Compensate the one cross-segment case:** `cd`/`pushd` to an out-of-repo path
  moves the *effective* root of a following search (`cd <outside> && grep -r x .`
  names only `.`). Per-segment classification alone drops it, so a preceding cd
  target is charged against the next in-scope search.
- **Where:** Hook — segment split + per-tool role resolution replacing the
  whole-string token scan, with a `__OK__` sentinel so a missing `python3` falls
  back to the whole-string scan rather than failing open. Skill text: "How it
  decides" steps 3 and 6, two new decision-table rows, and the false-blocks
  sub-bullet (an unrelated non-search segment no longer needs a call split).
  Nine new bats cases.
- **Reported mechanism was sharpened, not confirmed:** the field report said a
  plain non-recursive `grep -niE '<abs-shape>|…' <rel-file> <rel-file>` blocked.
  Driven directly against the hook, that shape exits 0 — a non-recursive grep is
  never inspected. It blocks only when the grep is recursive, or when any
  search-family binary appears elsewhere in the same command string (search-family
  detection was evaluated over the whole string while the token scan also spanned
  it). Both reproducible shapes were fixed; the report's own wording was not.
- **Regression caught mid-fold:** the first implementation reproduced the exact hole
  a prior pass had documented as a reason to reject per-segment attribution — the
  existing suite passed 32/32 while `cd <outside> && grep -r x .` silently went from
  block to allow. A recorded rejection is a coverage gap to test, not just prose to
  re-read: verify against the rejected case before adopting a rejected design.
