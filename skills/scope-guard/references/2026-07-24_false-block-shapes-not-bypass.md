---
class: principle
skill: wk-scope-guard
date: 2026-07-24
severity: medium
---

- **Rule:** A lexical scope guard produces false blocks; the response is to reshape
  the command, never to reach for the env opt-out. The opt-out is the user's to grant,
  not the agent's to self-authorize — a denial of a bypass retry is the correct
  outcome and is settled, not an obstacle. Two shapes read as out-of-scope while
  being in scope: an absolute path glued to a trailing shell separator; a search
  rooted in another repo's checked-out worktree. (A third shape recorded here —
  recursive flag plus unexpanded glob — was later disproved against the hook source
  and removed; see the quote-aware-tokenization reference.)
- **Why:** The guard inspects tokens without shell-expanding them, so a `cd <root>;`
  prefix yields the token `<root>;`, which matches neither the repo root nor its
  prefix — an in-scope path is judged outside. Stripping trailing `;&|)` before the
  comparison sharpens it in *both* directions (an out-of-repo `/etc;` still blocks),
  so it is a correctness fix, not a loosening. The worktree case is different in kind:
  the root resolves from the session's CWD, so any delegated cross-repo review trips
  every recursive search. A read-only single-pattern `git grep -n "<term>"` (no `-r`)
  passes cleanly and is the fallback that needs no bypass.
- **Where:** Hook token loop (strip trailing separators, skip an emptied token) plus
  two bats cases — one asserting the in-repo glued path now passes, one asserting an
  out-of-repo glued path still blocks. Skill text: merged the false-block cases into
  one "recognize the shape, never bypass" section, and added the self-authorization
  HARD RULE to the opt-out section.
- **Deliberately not promoted:** the source lesson proposed honoring a task-provided
  root for the turn. A guard that accepts an agent-supplied root is materially weaker
  than one deriving it from the environment — the very property that makes a hook
  un-rationalizable. Grant scope out-of-band instead.
