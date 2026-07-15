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
metadata:
  author: whizzzkid
  version: '2026.07.15-184218'
  model:
    openai: gpt-4.1-mini
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

| Action | Emoji | Example |
|--------|-------|---------|
| `fix` | 🐛 | `fix(parser): 🐛 handle empty input` |
| `feat` | ✨ | `feat(auth): ✨ add OAuth2 login` |
| `chore` | 🔧 | `chore(config): 🔧 tune lefthook timeouts` |
| `refactor` | ♻️ | `refactor(api): ♻️ extract middleware` |
| `docs` | 📝 | `docs(readme): 📝 update install guide` |
| `test` | 🧪 | `test(auth): 🧪 add token expiry tests` |
| `ci` | 👷 | `ci(deploy): 👷 add staging pipeline` |
| `perf` | ⚡ | `perf(query): ⚡ index hot lookup column` |
| `build` | 🏗️ | `build(deps): 🏗️ lock new dep tree` |
| `revert` | ⏪ | `revert(api): ⏪ revert middleware extraction` |

Full list: `skills/commit/references/emoji-cheatsheet.md`

**Exactly one emoji per commit subject. No stacking.**

- Pick the single most specific emoji that names the change.
- Primary action emoji + classifier both fit → **use the classifier** (more
  signal: `📌` beats `🔧` for a version pin; `⬇️` beats 🐛 for a downgrade).
- Two classifiers both relevant → pick the one a future reader would `grep` first.
- **Fallback when no emoji fits: 🤖** — for a change that defies classification
  (mixed-bag commit, agent-driven mechanical change with no single observable
  shape, "miscellaneous"). Use 🤖 rather than stacking emojis or picking a poor
  fit. 🤖 is also right for fully agent-authored commits with no human-curated
  intent.

| Pick this | Over this | Why |
|-----------|-----------|-----|
| `📌` | `🔧` | Pinning is the specific change; config tuning is the category |
| `⬇️` | `🐛` | Downgrade names the action; bug-fix is the outcome |
| `🛡️` | `✨` | Guardrail is the shape; feature is the bucket |
| `🤖` | `✨🐛` | One emoji always beats two |

Always pass commit messages via HEREDOC for correct formatting:

```bash
git commit -m "$(cat <<'EOF'
feat(scope): ✨ description of the change

Optional body with more detail.

Assisted-by: <Tool/Agent Name> <version>
Co-Authored-By: Agent Name <noreply@example.com>
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
  place alongside any `Co-Authored-By:` / `Generated with` trailers.
- Omit only for a purely human-authored commit with no agent involvement.
- Never invent a version — if unknown, use the tool name alone
  (`Assisted-by: <Tool/Agent Name>`).

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
   ```

3. Key loaded but env missing → run the commit through the user's shell (carries
   the env) or ask the user to run it directly. Do not declare the env broken.
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

#### "No signature" can be a local-verification false alarm

For SSH-signed commits, `git log --show-signature` reporting "No signature" (and
`%G?` returning `N`) does **not** mean the commit is unsigned. It usually means
`gpg.ssh.allowedSignersFile` is absent from the subprocess env (delivered via
`GIT_CONFIG_PARAMETERS` in the interactive shell, not inherited here), so git has
no public key to verify against — even though the commit object carries a valid
signature.

- Confirm the commit is actually signed before reacting — check the raw object
  for the signature header:

  ```bash
  git cat-file commit HEAD   # signed if: gpgsig -----BEGIN SSH SIGNATURE-----
  ```

- `gpgsig` header present → the commit IS signed. Never re-commit, re-sign, or
  delay a push on a "No signature" report alone.
- To verify locally, build a temp allowed-signers from the loaded key:

  ```bash
  git -c gpg.ssh.allowedSignersFile=<(ssh-add -L | \
    awk -v e="$(git log -1 --format='%ce')" '{print e, $1, $2}') \
    log -1 --show-signature
  ```

- The hosting service verifies against the account's registered keys server-side,
  so a locally-unverifiable-but-signed commit still lands as verified after push.

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

Project uses mise (`.mise.toml` or `.tool-versions`) → invoke push (and any
commit-time hook trigger) via `mise exec --` so git hooks (lefthook, husky, etc.)
find mise-managed binaries:

```bash
mise exec -- git push
```

Never use `eval "$(mise activate bash)"` — the supported single-command form is
`mise exec --`. Bash tool sessions don't inherit the user's interactive shell, so
without `mise exec --` hooks fail with "command not found" (exit 127) for tools
like `lychee`, `shellcheck`, `bats`, etc.

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

`git commit` commits the **whole index**, not only the paths named in the
preceding `git add`. Anything already staged — a prior `git mv`, an earlier
`git add` — rides into the commit and merges two logical groups.

- Before each grouped commit, confirm the staged set is exactly the intended group:

  ```bash
  git diff --cached --name-only
  ```

- Unstage strays with `git restore --staged <paths>` (or `git stash`) before
  committing. Treat `git mv` as already-staged.

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

Repo ships a prohibited-terms file (commonly `.prohibited-terms`, `.denylist`, or
similar gitignored config) → the `commit-msg` hook should read it and block any
matching message. When installing or updating commit hooks, verify prohibited-term
matching is included.

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
  the end of the body. If the existing body already contains the footer, do not
  duplicate it on edit.
- Unsure whether a section is human- vs agent-authored → ask the user before
  overwriting. Better to ask once than clobber a hand-edited test plan.

### Step 4: Report

Tell the user explicitly that the PR was synced (or that no drift was found):

> "Pushed to `<branch>`. PR #<N> title/body updated to reflect the new
> commits."

Or:

> "Pushed to `<branch>`. PR #<N> already in sync — no edit needed."

Silence after a push that touched an open PR is itself a violation of this rule.

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
ready, check whether the branch has a long tail of small `fix(ci):` commits that
would be more readable as one.

**Detection:** count commits on the branch ahead of the base whose message
matches `^fix(\(ci\))?:`. Count ≥3 **and** net diff across those commits small
(<50 lines, single config file or a handful of related ones) → offer to squash
them into a single commit naming the actual change that shipped:

```bash
BASE=$(gh pr view --json baseRefName --jq .baseRefName 2>/dev/null || echo "main")
N=$(git log --oneline "$(git merge-base HEAD "$BASE")..HEAD" \
    --grep '^fix(\(ci\))\?:' | wc -l | tr -d ' ')
LINES=$(git diff "$(git merge-base HEAD "$BASE")..HEAD" \
    -- $(git log --name-only --pretty=format: "$(git merge-base HEAD "$BASE")..HEAD" \
    --grep '^fix(\(ci\))\?:' | sort -u) | wc -l | tr -d ' ')
```

If `N >= 3 && LINES < 50`, ask:

> "The branch has {N} `fix(ci):` commits whose net diff is {LINES}
> lines. Want me to squash them into a single
> `fix(ci): <emoji> <what-actually-shipped>` commit before marking the
> PR ready? (a) yes  (b) keep separate"

**Rules:**

- **Do not auto-squash.** This is destructive — the user must approve.
- **Do not squash across user-authored commits.** Only squash the agent's own
  back-to-back CI fix commits. User commit in the middle → leave the chain intact.
- **Force-push is required after squash.** Confirm the user accepts the force-push
  before rewriting history on a pushed branch.
- **Use the new subject to name the actual fix**, not the journey.
  "fix(ci): ⬇️ downgrade and pin {dep} {version}" beats "squashed CI fix attempts."

User declines or thresholds not met → leave history alone.

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
