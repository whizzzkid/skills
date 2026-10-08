# Staging Discipline

## Stage Handoff-Doc Removal with the Work

Applying an agent-written handoff document (e.g. `NEXT_PHASE.md`, `HANDOFF.md`, a
planning markdown left by a prior session) → delete the handoff file in the
**same commit** that applies the work — not a separate cleanup commit.

- The deletion is logically part of completing the handoff; a follow-up commit
  produces a diff that only removes a markdown file.
- A markdown-only commit triggers a full CI run on no real change, wastes CI time,
  and can surface flaky failures unrelated to the work.

```bash
git add <implementation files> <handoff doc>
git commit -m "feat: ✨ apply X (removes NEXT_PHASE.md handoff)"
```

## Exclude Ephemeral Working Docs from Commits

Planning/working artifacts (plan docs, scratch notes, agent handoff files) are
not history — only settled docs (specs, ADRs) belong in committed history.

- Before `git add` on any docs path, confirm the repo's convention commits it.
  Many repos track `docs/specs/` and `docs/adr/` but treat `docs/plans/` (and
  equivalents) as ephemeral — never stage those.
- Staging everything under `docs/` blindly leaks plan docs into the PR. Add
  spec/ADR paths explicitly; exclude the working-artifact dirs.
- **Exception — user-directed in-repo artifacts are deliverables, not scratch.**
  When the user explicitly directs artifacts to a specific in-repo path (not a
  known-ephemeral dir), stage them with the work by default — never silently
  withhold them as scratch (else the user must ask again to include them).

## Verify the Staged Set Before a Grouped Commit

**HARD RULE — dependent commit chains fail fast.** Begin every multi-command stage/verify/commit shell with
`set -euo pipefail`; a failed stage or verification must stop the commit and any success-looking tail output.

`git commit` records the whole index, so earlier staged paths ride along.

- Before each grouped commit, require staged paths to equal the intended set:

  ```bash
  git diff --cached --name-only
  ```

- Unstage strays with `git restore --staged <paths>` (or `git stash`). Treat `git mv` as already staged.

## Stage Generated Artifacts Individually

Generated artifacts derived from mutable local state (ORM/type stubs, RBI/schema
dumps, snapshot fixtures) are not deterministic from the branch's own source. On a
shared machine a sibling branch's migration pollutes the local DB/cache, so
regeneration emits accessors/columns absent from this branch's schema; CI
regenerates against clean state and the verify gate fails on the diff. The
staged-set check above catches strays, not a legitimately-touched-yet-polluted
generated file.

- Stage generated artifacts one path at a time — never `git add <generation-dir>`.
- On a branch that changes none of an artifact's source, restore it to base
  instead of trusting local regeneration:

  ```bash
  git checkout <base> -- <generated-path>
  ```

- Only artifacts genuinely changed by this branch's source (e.g. route-helper
  stubs on a routes-only PR) should differ from base.
- **Required regeneration with host-varying output → declare it, never restore.** A
  platform-stamped artifact (`IS_MAC` predicates, libc constants) regenerated on the
  mandated host is legitimate, so the base-restore above does not apply. Name in the
  body: generator, platform it ran on, platform the committed version came from, and
  which hunks are platform churn, not change-driven. No verify gate for that
  class → flag it as a follow-up.
