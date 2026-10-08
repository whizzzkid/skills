# Conflict Resolution Loop

Merging, rebasing, or patch-applying surfaces conflicts the same way — files
with `<<<<<<<` markers, `git status` listing "both modified."

```bash
git status --short | grep '^UU\|^AA\|^DD'
```

**HARD RULE — never trust a rerere-cached resolution.** When merge/rebase/patch prints
`Staged '<file>' using previous resolution`, `rerere.enabled` silently re-applied a
prior resolution by content hash and left **no conflict markers** — a wrong-direction
cached resolution (e.g. one that dropped this branch's own additions) applies invisibly,
and `git diff --check` finds nothing because the file is already staged.

- Do not accept the staged result. Recreate the real conflict and re-resolve by hand:

  ```bash
  git rerere forget <file>
  git checkout --merge <file>   # restores <<<<<<< markers for manual resolution
  ```

- Hand-verify **both sides are represented** in the final result before staging.
- **Important:** regenerate any build/generate output (schema dumps, digest manifests,
  screenshots, lockfiles) from source and verify; never side-pick or textually resolve.
  Regenerate **once, last** — any later source commit re-invalidates it, so resolve
  either way, mark the path, and generate after all other fixes land, as the final
  pre-push commit.

For each conflicted file:

1. **Read** both sides. Marker labels change meaning by operation: during a
   merge, `HEAD` is the current branch; during a rebase, `HEAD` is the replay
   target; during patch-replay, the other side is the patch. Inspect the named
   refs or index stages instead of assuming one label always means "base."
2. **Decide** the resolution. Prefer keeping the branch's intent (the work being
   integrated is why the PR exists) unless the base change supersedes it (e.g. file
   renamed on base → apply the branch's edits to the new filename).
   - **Lockfile conflict** (`Gemfile.lock`, `package-lock.json`, `Cargo.lock`, …):
     keep the branch's structural changes (remotes, added/removed deps, source
     migration) and re-apply only the base's dependency version bumps onto it —
     never take one whole side. A real install from the resolved manifest
     (Stage 5 pre-check) outranks a clean-looking textual merge.
3. **Verify** the resolved file — open it, scan for stray markers, run a quick syntax
   check (`node --check`, `python -m py_compile`, `cargo check`, etc. — whatever is cheap
   for the language).
4. **Stage**: `git add <file>`.

Auto mode resolves only **trivial** conflicts (non-overlapping additions, whitespace).
Semantic conflicts pause and prompt: path + excerpt, options (a) branch (b) base (c) manual (d) abort.

After all files are resolved:

- **Merge:** `GIT_EDITOR=true git merge --continue` (`--no-edit` is invalid on
  `--continue`). Proceed to Stage 5 after the integration commit is created.
- **Rebase:** `git rebase --continue`. Loop if more conflicts.
- **Patch-replay:** working tree now has a clean diff → proceed to the integration
  commit (Stage 3c step 4).

Conflicts too tangled to resolve cleanly → **abort** and restore the starting state:

```bash
git merge --abort 2>/dev/null
git rebase --abort 2>/dev/null
git reset --hard "$START_SHA"
```

Report: conflicts unresolvable, branch at `$START_SHA`. Resolve manually and re-run.
