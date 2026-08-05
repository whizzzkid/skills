---
name: wk-commit
description: >-
  Use when creating git commits or pushing code. Enforces conventional commits
  with emoji, commit signing, and safe push behavior. Use for all git commit
  and push operations.
allowed-tools:
  - "Bash(git add:*)"
  - "Bash(git commit:*)"
  - "Bash(git push:*)"
  - "Bash(git stash:*)"
  - "Bash(git status:*)"
  - "Bash(git diff:*)"
  - "Bash(git log:*)"
  - "Bash(gh pr view:*)"
  - "Bash(gh pr edit:*)"
  - "Bash(gh pr list:*)"
  - AskUserQuestion
model: sonnet
effort: low
model-invocable: true
user-invocable: true
license: MIT
group: workflows
env-vars:
  - WK_SKILLS_EMPLOYEE_EMAIL
metadata:
  author: whizzzkid
  version: "2026.08.05-205509"
  model:
    openai: gpt-5.6-terra
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-2
---

# Commit

Git commit and push workflow enforcing conventional commits with emoji, signed
commits, and safe push behavior.

## Commit Message Format

- Conventional commits with emoji after the colon. Emoji is REQUIRED.
- **Format:** `<action>(optional scope): <emoji> work-done`

### Primary action emojis

Pick the emoji matching the conventional-commit action:

| Action | Emoji |
|--------|-------|
| `fix` | 🐛 |
| `feat` | ✨ |
| `chore` | 🔧 |
| `refactor` | ♻️ |
| `docs` | 📝 |
| `test` | 🧪 |
| `ci` | 👷 |
| `perf` | ⚡ |
| `build` | 🏗️ |
| `revert` | ⏪ |

Full list: `skills/commit/references/emoji-cheatsheet.md`

**Exactly one emoji per commit subject. No stacking.**

- Pick the single most specific emoji that names the change.
- Primary action emoji + classifier both fit → **use the classifier** (more
  signal: `📌` beats `🔧` for a version pin; `⬇️` beats 🐛 for a downgrade; `🛡️`
  beats ✨ for a guardrail).
- Two classifiers both relevant → pick the one a future reader would `grep` first.
- **Fallback when no emoji fits: 🤖** — for a change that defies classification
  (mixed-bag commit, agent-driven mechanical change with no single observable
  shape, "miscellaneous"). Use 🤖 rather than stacking emojis or picking a poor
  fit. 🤖 is also right for fully agent-authored commits with no human-curated
  intent.

Always pass commit messages via HEREDOC for correct formatting:

```bash
git commit -m "$(cat <<'EOF'
feat(scope): ✨ description of the change

Optional body with more detail.

Assisted-by: <Tool/Agent Name> <version>
EOF
)"
```

### Mandatory footer trailer — `Assisted-by:`

**HARD RULE — every agent-created commit carries an `Assisted-by:` trailer.**
This skill is model-invocable → any commit it produces is agent-created.

- Append to the footer (trailer block after the blank line ending the body):

  ```
  Assisted-by: <Tool/Agent Name> <version>
  ```

- Fill both fields from the **running agent**: tool/CLI name + model or release
  version (e.g., `Assisted-by: Claude Code (claude-opus-4-8)`).
- One `Assisted-by:` line per distinct agent that materially authored the commit;
  place alongside any co-author / `Generated with` trailer the rules below admit.
- Omit only for a purely human-authored commit with no agent involvement.
- Never invent a version — if unknown, use the tool name alone
  (`Assisted-by: <Tool/Agent Name>`).

### HARD RULE — the trailer set is closed; never copy a neighbour's

- `Assisted-by:` is the only trailer this skill adds on its own initiative.
- Any other trailer lands **only** where the user, or an invoking skill's explicit
  directive, calls for it on that commit — never inferred from sibling commits,
  branch history, or the mere availability of an employee-email env var.
- Never derive a trailer block from neighbouring commits: a human stamped one
  there by decision, and that decision does not transfer.

### HARD RULE — never fabricate a `Co-Authored-By:` email

- Never build a human's email from a GitHub login + a guessed domain
  (`<login>@<company>`) — a fabricated address misattributes every commit.
- Current user's co-author trailer, **once directed per the closed-set rule
  above** → use `$WK_SKILLS_EMPLOYEE_EMAIL` verbatim.
- **`$WK_SKILLS_EMPLOYEE_EMAIL` unset/empty → STOP.** Do not emit a human
  co-author trailer; require the var (never guess, never silently omit it).
- Another person's co-author → their `<id>+<login>@users.noreply.github.com`
  form only; omit the email if unknown. Never a corporate-domain guess.

## Commit Signing

All commits MUST be signed. Never use `--no-gpg-sign`, `-n`, or
`git -c commit.gpgsign=false`.

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
   [literal-key probe](references/2026-07-24_signingkey-literal-not-path.md).
3. **Match the execution context.** Before committing in a linked/temporary
   worktree, probe `git -C <worktree> config --get user.signingkey` from the
   exact shell that will commit. Missing there but present in the user's shell →
   run `git -C` through that shell; launch cwd does not carry config. Verify the
   resulting raw commit has a `gpgsig` header. Do not declare the env broken.
   [Temporary-worktree signing](references/2026-07-30_temp-worktree-signing-context.md).
4. Tell the user: "Commit signing failed. Please check your GPG/SSH agent
   configuration and try again."
5. Do not attempt any workaround that disables signing.

**HARD RULE — never write git config to fix a signing failure.**
`git config --global user.signingkey` and `git config --global gpg.*` writes are
permanently destructive to env-based config management: they shadow the user's
`GIT_CONFIG_PARAMETERS`-delivered config and persist as global state. Never run
them without explicit user instruction — diagnose env inheritance (step 2) instead.

### Preserve signatures when rewriting history

History rewrites (rebase, amend, cherry-pick, squash, `filter-branch`) re-create
commits and drop the original signature unless re-signed.

- Re-sign every commit a rewrite touches — never let a rewrite emit unsigned commits.
- Confirm `commit.gpgsign=true` is active, or pass `-S` explicitly
  (`git rebase -S`, `git commit --amend -S`). Never `--no-gpg-sign`.
- Verify after any rewrite that every rewritten commit is still signed:

  ```bash
  git log --show-signature <base>..HEAD
  ```

- A rewritten commit that loses its signature drops verified status and can fail
  branch protection requiring signed commits.
- **A trailer edit on already-pushed commits is a history rewrite — its real cost
  is the fan-out of SHAs recorded outside git.** Before rewriting, enumerate every
  place a rewritten SHA was recorded (plan docs, PR body, tracking issues, review
  comments); after, remap old→new and re-verify each with an ancestry check.
  The sweep belongs to the same task, never a follow-up; confirm zero stale
  references before returning control.

#### "No signature" can be a local-verification false alarm

- An SSH-signed commit reported "No signature" (or `%G?` = `N`) is usually
  *unverifiable*, not unsigned — `gpg.ssh.allowedSignersFile` arrives via
  `GIT_CONFIG_PARAMETERS` in the interactive shell and is not inherited here, so
  git has no public key to check against.
- Confirm from the raw object before reacting; `gpgsig` header present → signed:

  ```bash
  git cat-file commit HEAD   # signed if: gpgsig -----BEGIN SSH SIGNATURE-----
  ```

- Never re-commit, re-sign, or delay a push on a "No signature" report alone.
- The hosting service verifies server-side, so a locally-unverifiable-but-signed
  commit still lands verified after push. Local-verify command:
  [no-signature false alarm](references/2026-06-01_ssh-sig-no-signature-false-alarm.md).

## Pushing

- **Push after every commit unless the user explicitly said not to.** A commit
  without a push leaves work invisible to the team and easy to lose. The push is
  not a separate step the user must request — it is the tail of the commit sequence.
- **First push of a brand-new branch with no PR → confirm intent first.** The push
  mandate above applies once a branch has an upstream or an open PR. When `gh pr
  view 2>/dev/null` finds no open PR **and** the push would create a *new* remote
  branch (no upstream tracking), pause and confirm before pushing — an orphaned
  remote branch is visible to teammates with no PR context and harder to reason
  about. **Exception — auto mode + authorizing directive:** when auto mode is on
  *and* the session's originating prompt already authorizes a published/tracked
  PR (e.g. *create a ticket to track this*, *open a PR*, *ship X*), the new-branch
  state is expected, not a surprise — skip the confirm and push. Confirm only on
  genuinely ambiguous intent; the no-upstream signal alone does not mean unclear
  intent. Detect the new-branch case:

  ```bash
  git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null \
    || echo "no upstream — first push, confirm intent"
  ```
- Push blocked (branch protection, no upstream branch, rejection) → report it
  explicitly to the user. Never silently skip the push.
- Pre-push hooks run → emit a one-line note before `git push` that hooks may take
  ~30s, then report the result when it returns. Silence during a long hook run
  reads as a frozen session and invites a "is this stuck?" interrupt.
- Always use regular `git push`. Never `--force` or `--force-with-lease` unless:
  - The user explicitly asks for a force push.
  - Commits were rewritten (rebase/amend) and the branch was already pushed.

### Mise-managed repos

Repo has `.mise.toml` / `.tool-versions` → run push and any commit-time hook
trigger as `mise exec -- git push`; never `eval "$(mise activate bash)"`. Without
it hooks exit 127 (`command not found`) for mise-managed tools. Rationale:
[`references/2026-05-28_mise-exec-not-activate.md`](references/2026-05-28_mise-exec-not-activate.md).

### Hook and verify rules

- Never use `--no-verify` when committing or pushing. Hook failing → stop and ask
  the user to run the command manually, unless it is a self-healing class below.
- **Never truncate `git commit` output so a hook abort is hidden.** A short
  `| tail -N` drops both the hook's `✗`/error block and the `[branch sha]`
  success line, so a *blocked* commit reads as success. Show full output or
  append `&& echo OK`, and confirm HEAD advanced (`git rev-parse HEAD`); treat an
  absent `[branch sha]` confirmation as a failed commit, not a display artifact.
- **Self-heal stale-bundle hook failures.** A pre-push hook failing with
  `GemNotFound` / `Bundler::GemNotFound` / `Could not find gem` (stale local bundle
  after a base bump or rebase) → run `bundle install`, then retry the push once.
  Escalate only if `bundle install` fails or the hook fails again after it.
- Regular push rejected → tell the user and ask how to proceed rather than
  automatically force-pushing.
- Push rejected non-fast-forward (remote diverged) → default to `git pull
  --no-rebase` (merge), then retry the regular push. Rebasing rewrites published
  commits and forces a force-push the classifier blocks; only rebase when the
  user explicitly asks for clean linear history.
- Force-push classifier-blocked after an authorized rewrite → surface the exact
  `git push --force-with-lease` (never `--force`) for one-time approval in the
  same response; the denial needs approval, not a hard stop. If declined, push
  the rewritten commits under a **new branch name** (a plain new-ref push lands
  cleanly) and repoint the PR. Never `--no-verify` or otherwise bypass the block.

### Stage handoff-doc removal with the work it describes

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

### Exclude ephemeral working docs from commits

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

### Verify the staged set before a grouped commit

**HARD RULE — dependent commit chains fail fast.** Begin every multi-command stage/verify/commit shell with
`set -euo pipefail`; a failed stage or verification must stop the commit and any success-looking tail output.

`git commit` records the whole index, so earlier staged paths ride along.

- Before each grouped commit, require staged paths to equal the intended set:

  ```bash
  git diff --cached --name-only
  ```

- Unstage strays with `git restore --staged <paths>` (or `git stash`). Treat `git mv` as already staged.

### Stage generated artifacts individually — never blanket `git add` the output dir

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

### Re-stage a file edited after it was staged

`git add` snapshots the working tree at the moment it runs — later edits update
the working tree but leave the staged snapshot stale. Pre-commit hooks (RuboCop,
formatters) inspect the **staged** content, so they flag offenses already fixed
in the working tree and block the commit.

- After any Edit/Write to a file already in the index, re-run `git add <file>`
  before committing.
- Detect the gap — overlap between working-tree and staged changes means a
  re-stage is needed:

  ```bash
  comm -12 <(git diff --name-only | sort) <(git diff --cached --name-only | sort)
  ```

### Read committed content without mutating the tree

To inspect a committed or staged version mid-run, use read-only `git show` —
never `git stash`, `git checkout`, or `git reset`, which revert or discard the
in-progress working tree.

- Committed file at HEAD → `git show HEAD:<path>`; staged blob → `git show ":<path>"`.
- `git stash` (no `--keep-index`) stashes staged + unstaged changes and resets
  the tree to HEAD → silently reverts in-progress edits. Recovery needs `git
  stash pop` of the right entry, made worse by unrelated stashes from other sessions.
- Before any `stash`/`checkout`/`reset` in a run with uncommitted work, stop and
  confirm it is intended.

## Prohibited Terms in Commit Messages

**HARD RULE:** Never name prohibited or internal tokens (vendor codenames,
internal project names, ticket-system prefixes on the denylist, etc.) in
commit messages, PR titles, or issue text — even when the commit's purpose
is to remove those tokens from files.

- Commit messages are permanent git history; they survive any file-level
  scrub. A "describe what was removed" message re-leaks the token into
  history, defeating the cleanup.
- Describe the change by **category**, not by token name:
  - ✅ `chore: 🔧 scrub internal vendor codenames from committed files`
  - ❌ `chore: 🔧 remove ACME_INTERNAL and project-X from files`
- Same rule applies to PR descriptions, review comments, and issue bodies — any
  text that touches a hosted service.

### Enforcement

Repo ships a prohibited-terms file (`.prohibited-terms`, `.denylist`, or similar
gitignored config) → the `commit-msg` hook must read it and block any matching
message. Verify that matching is wired in when installing or updating commit hooks.

## Post-Push: PR Sync

**HARD RULE:** After every successful push to a branch with an open PR, the PR
title and description MUST be re-checked against the post-push branch state and
updated if drifted. No exceptions.

Drift signals to a reviewer that the agent shipped without re-reading its own
work. The PR is the source of truth for everyone except the author — leaving it
stale silently changes what reviewers approve.

**HARD RULE — push first, then sync the body. Never the reverse.** The PR body's
commit SHAs, ref links, and "current behavior" narrative are only correct *after*
the push lands. Editing the body before pushing bakes in stale refs you then
re-edit — two round-trips for one sync. Fixed order: full pre-push gate →
`git push` → detect drift → edit the body. Any branch-ref-dependent step (body
sync, "Closes #N" verification, self-review SHA links) waits for the push.

### Step 1: Detect whether a PR exists

After `git push` returns success:

```bash
gh pr view --json number,title,body,headRefName,state 2>/dev/null
```

- Exit code non-zero or `state != OPEN` → no open PR; skip the rest of this section.
- Otherwise capture `number`, `title`, `body` for comparison.

### Step 2: Check for drift

Compare the PR's current title and body against the branch's post-push state:

| Drift signal | Example |
|---|---|
| Title no longer matches primary intent | scope flipped feat→fix; version pin landed but title still says "upgrade" |
| Body lists commits/behaviors that no longer exist | removed commits, reverted decisions still described as live |
| Test plan / Closes section is now wrong | steps reference removed code; linked issue closed by a different PR |
| Body cites a version or config value the push changed | dep version in body doesn't match lockfile |

A clean push that only adds tests/docs aligned with the existing description is
**not** drift.

### Step 3: Update on drift

Drift detected → update the PR before returning control:

```bash
gh pr edit <number> --title "<new-title>" \
  --body "$(cat <<'EOF'
<refreshed body>
EOF
)"
```

Rules for the refresh:

- Preserve any `Closes #N` / `Fixes #N` / `Refs #N` annotations unless now wrong.
- Preserve human-authored sections (reviewer notes, test plan checks the user
  added). Do not overwrite review checkboxes a human ticked.
- Reflect the **current** set of commits and the **current** behavior — not the
  historical narrative of how the branch evolved.
- Keep the title under ~70 chars; details belong in the body.
- **Route through `wk-gh`.** Any `gh pr edit --body` issued by this skill ends
  with the canonical outbound footer per `wk-gh` Step 4 — emitted exactly once at
  the end of the body.
- **Important:** a body sync is not complete until the footer gate runs on the
  NEW body string — never the one it replaced. An inherited body is the usual
  carrier of the wrong block: the commit-message trailer and the canonical
  outbound footer open alike, so a carried-over trailer passes an "already has a
  footer" glance. Match the exact canonical string; replace a trailer variant,
  never preserve it.
- Unsure whether a section is human- vs agent-authored → ask the user before
  overwriting. Better to ask once than clobber a hand-edited test plan.

### Step 4: Report

State the outcome explicitly — `Pushed to <branch>. PR #<N> title/body updated`,
or `… already in sync — no edit needed`. Silence after a push that touched an open
PR is itself a violation of this rule.

## Post-CI-Fix Squash Offer

### Single trivial follow-up → offer `--amend` at the fix site

When a CI fix produces one trivial follow-up that is clearly a correction to the
*immediately prior* commit, surface an explicit `--amend` suggestion for the user
to approve in the same response — do not silently create a separate commit and
defer cleanup to retro.

- Auto mode blocks `git commit --amend` as history-rewriting → it needs explicit
  user confirmation. Ask once, at the fix site, rather than accumulating commits
  the user must later squash by hand (`git rebase -i HEAD~N`).
- **The amend prohibition holds regardless of push state.** An unpushed commit is
  not a license to self-initiate `--amend` — unpushed status changes the blast
  radius, not the rule. Fold a follow-up by creating a NEW commit; surface the
  amend/squash as an explicit suggestion for the user to approve.
- Prior commit already pushed → the amend forces a force-push; flag that in the
  same ask (force-push rules below apply).

After the CI fix loop (`wk-workflow` Phase 6) exits green, before marking the PR
ready, offer to squash a long tail of small `fix(ci):` commits into one.

- Threshold: ≥3 commits matching `^fix(\(ci\))?:` ahead of base **and** their net
  diff <50 lines (single config file or a handful of related ones). Detection
  commands and ask template:
  [`references/ci-fix-squash-detection.md`](references/ci-fix-squash-detection.md).
- **Do not auto-squash** — destructive; the user must approve.
- **Never squash across user-authored commits.** A user commit mid-chain → leave
  the chain intact.
- **Confirm the force-push** a squash forces on an already-pushed branch.
- **Name the actual fix in the new subject, not the journey** —
  `fix(ci): ⬇️ downgrade and pin {dep} {version}` beats "squashed CI fix attempts".
- Thresholds unmet or user declines → leave history alone.

## Quick Reference

| Trigger | Behavior |
|---------|----------|
| "commit this" | Stage relevant files, create signed commit with conventional format |
| "push" | Regular push, ask on rejection |
| Signing failure | Stop, tell user to fix GPG/SSH config |
| Hook failure | Stop, ask user to run manually |
| Push succeeded + open PR exists | Run PR Sync — diff title/body vs branch, `gh pr edit` if drifted |
| Push succeeded + no PR | Skip PR Sync silently |
| First push of new branch + no PR | Confirm push intent — unless auto mode + originating directive authorizes a tracked PR (then push) |
| Message names a prohibited token | Stop — rewrite using category description only |

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument (e.g., `wk-learn commit`).
