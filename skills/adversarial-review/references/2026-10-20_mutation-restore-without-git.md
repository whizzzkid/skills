---
class: principle
---

# Restore mutants from a copy, never through VCS

**Rule** — Before applying a mutant, copy the target file into `.review-playground/`. After the run, restore it on the
host from that copy and `cmp` it against the copy before the next mutation. Never restore with `git checkout`,
`git restore`, or `git stash`.

**Why** — A VCS restore assumes a clean tree and a reachable git dir; both fail in ordinary review setups:

- Dirty tree on the host: `git checkout <file>` resets to the index and silently discards the uncommitted fix along
  with the mutant (reproduced: the file came back as the committed version).
- Inside a container: a worktree's `.git` is a file (`gitdir: <host path>`) that the container cannot resolve, so git
  exits 128 (`fatal: gitfile does not point to a valid repository`) and the mutant stays in the file.
- A `cmp` against the copy proves the restore; an exit-0 restore command does not.

**Where** — `wk-adversarial-review` Step 5 (Playground Validation), mutation bullet. Same mechanic corrected in
`wk-testing-skeleton` Stage 4 step 4 and `wk-pr-review`'s stale-snapshot mutant probe.
