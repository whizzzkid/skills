# Commit Signing

All commits MUST be signed. Never use `--no-gpg-sign`, `-n`, or
`git -c commit.gpgsign=false`.

## Pre-Signing Verification

**Before a signed merge or rewrite**, verify `user.signingkey` and `ssh-add -L`
from the exact execution shell. Direct shell missing either but login shell has
both → run the operation there with the verified key via one-shot `git -c`;
never start first or weaken signing.

## Signing Failure Diagnosis

**On signing failure** (errors like `gpg failed to sign the data`,
`Couldn't get agent socket`, `failed to write commit object`,
`user.signingkey not set`):

1. **Stop immediately.** Do not retry without signing.
2. **Diagnose env inheritance before touching any git config.** Signing config
   is often delivered via `GIT_CONFIG_PARAMETERS` (git-native injection set in
   the user's interactive shell) that a subprocess does not inherit — config is
   present, just not visible in this process.

   ```bash
   echo "$GIT_CONFIG_PARAMETERS"   # signing config present but not inherited?
   ssh-add -l                       # agent holds the signing key?
   git config user.signingkey; ssh-add -L   # SSH signing: is the CONFIGURED key among the LOADED ones?
   ```

2b. **SSH signing (`gpg.format=ssh`), error `Couldn't find key in agent?`:**
   compare the configured key against the loaded set before proposing anything. A
   configured key present but ABSENT from `ssh-add -L` means the agent rotated /
   re-provisioned it mid-session (common with hardware-backed / auto-provisioning
   agents) — the key is not loaded, not misconfigured. Ask the user to re-add that
   exact key to the agent; never a config change. Only an entirely empty agent
   means no signing key at all.

2c. **Materialize `user.signingkey` before any file-taking probe flag.** A
   literal passed as a filename produces a probe defect, not signing evidence.
   Only a completed signed commit proves capability:
   [literal-key probe](2026-07-24_signingkey-literal-not-path.md).
3. **Match the execution context.** In a linked/temporary worktree, repeat the
   preflight with `git -C <worktree>`; only a raw `gpgsig` proves success.
   [Temporary-worktree signing](2026-07-30_temp-worktree-signing-context.md).
4. Tell the user: "Commit signing failed. Please check your GPG/SSH agent
   configuration and try again."
5. Do not attempt any workaround that disables signing.

**HARD RULE — never write git config to fix a signing failure.**
`git config --global user.signingkey` and `git config --global gpg.*` writes are
permanently destructive to env-based config management: they shadow the user's
`GIT_CONFIG_PARAMETERS`-delivered config and persist as global state. Never run
them without explicit user instruction — diagnose env inheritance (step 2) instead.

## Preserve Signatures When Rewriting History

History rewrites (rebase, amend, cherry-pick, squash, `filter-branch`) re-create
commits and drop the original signature unless re-signed.

- Re-sign every commit a rewrite touches — never let a rewrite emit unsigned commits.
- Confirm `commit.gpgsign=true` is active, or pass `-S` explicitly
  (`git rebase -S`, `git commit --amend -S`). Never `--no-gpg-sign`.
- Verify after any rewrite that every rewritten commit is still signed — raw `gpgsig`
  per commit, never `--show-signature`, which reports unsigned when
  `gpg.ssh.allowedSignersFile` is unset:

  ```bash
  for c in $(git rev-list <base>..HEAD); do
    git cat-file commit "$c" | grep -q '^gpgsig' || echo "UNSIGNED $c"; done
  ```

- A rewritten commit that loses its signature drops verified status and can fail
  branch protection requiring signed commits.
- **A trailer edit on already-pushed commits is a history rewrite — its real cost
  is the fan-out of SHAs recorded outside git.** Before rewriting, enumerate every
  place a rewritten SHA was recorded (plan docs, PR body, tracking issues, review
  comments); after, remap old→new and re-verify each with an ancestry check.
  The sweep belongs to the same task, never a follow-up; confirm zero stale
  references before returning control.

### "No signature" can be a local-verification false alarm

- An SSH-signed commit reported "No signature" (or `%G?` = `N`) is usually
  *unverifiable*, not unsigned — `gpg.ssh.allowedSignersFile` arrives via
  `GIT_CONFIG_PARAMETERS` in the interactive shell and is not inherited here, so
  git has no public key to check against.
- Confirm from the raw object before reacting; a `gpgsig` header means signed (command
  above, or `git cat-file commit HEAD` for a single commit).

- Never re-commit, re-sign, or delay a push on a "No signature" report alone.
- The hosting service verifies server-side, so a locally-unverifiable-but-signed
  commit still lands verified after push. Detail:
  [no-signature false alarm](2026-06-01_ssh-sig-no-signature-false-alarm.md).
