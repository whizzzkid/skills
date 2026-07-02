---
skill: wk-sharpen
date: 2026-07-02
type: gap
severity: medium
---

The `check-relative-paths` hook blocked a fold because the lesson's own subject was a home-rooted path literal, discovered only at commit time.

**What happened:** A learning about a bash tilde-expansion gotcha necessarily wrote a tilde-slash-prefixed literal in its examples. `check-relative-paths` blocks any bare tilde-slash (home-rooted path) in added lines and matches shape, not intent — so it flagged the SKILL edit, the reference, and the staged `.learned.md`/retro archives. The collision surfaced at the Step 8 commit, forcing a rework-and-re-stage cycle.

**Root cause:** Same class as the prohibited-subject gate (`.skillprohibit`), but for a path *shape* rather than a term list. The distill-time scan only checks `.skillprohibit` terms; it does not anticipate that a lesson whose subject IS a machine-path shape (user-dir, home-dir, bare tilde-slash) will collide with `check-relative-paths`. A lesson *about* a path token can only produce edit text containing that token — knowable at distill, not commit.

**Suggested fix:** Extend the Step 3 prohibited-subject gate (and Step 5 mechanical overfit scan) to also grep the lesson's core token against the home-path shapes `check-relative-paths` blocks, before drafting. On match: rework the example to break the tilde-slash adjacency (bare-tilde `*'~'*` glob + prose describing the tilde-prefixed path, or `$HOME`-rooted forms) and scrub the same shape in every staged `.learned.md`/retro archive up front — never place-then-reclaim at commit.
