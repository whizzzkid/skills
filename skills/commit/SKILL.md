---
name: wk-commit
description: >-
  Use for all git commit and push operations. Enforces conventional commits
  with emoji, commit signing, and safe push behavior.
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
  version: "2026.10.09-171327"
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

Pick the emoji matching the conventional-commit action — every action's mapping with a
worked example: `skills/commit/references/emoji-cheatsheet.md`

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
  version (e.g., `Assisted-by: Claude Code (claude-opus-4-7)`).
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
- **Self-attribution is redundant:** even when directed, skip `Co-authored-by:`
  for the current user when they match the PR author.

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
`git -c commit.gpgsign=false`. On failure, diagnose env inheritance before
touching config. Never write `git config --global` to fix signing. Re-sign
every commit a rewrite touches. "No signature" is usually a local-verification
false alarm — check the raw `gpgsig` header.

Full signing diagnosis, rewrite preservation, and false-alarm rules:
[`references/commit-signing.md`](references/commit-signing.md).

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
  *and* an originating prompt or repo mandate authorizes a published/tracked PR
  (e.g. *create a ticket to track this*, *open a PR*), the new-branch
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

### Staging Discipline

Delete handoff docs in the same commit as the work they describe. Exclude
ephemeral working docs (`docs/plans/`). Verify staged set matches intent before
grouped commits (`git diff --cached --name-only`). Stage generated artifacts
individually — never blanket `git add` a generation dir.

Full rules: [`references/staging-discipline.md`](references/staging-discipline.md).

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

**HARD RULE:** After every push to a branch with an open PR, re-check the PR title
and body against post-push state and update if drifted. Push first, then sync —
never the reverse. Preserve human-authored sections; route through `wk-gh` Step 4
for the footer gate.

Full drift detection, refresh rules, and report format:
[`references/pr-sync.md`](references/pr-sync.md).

## Post-CI-Fix Squash Offer

Surface `--amend` for single trivial follow-ups; offer batch squash when ≥3
`fix(ci):` commits with <50 lines net diff. Never auto-squash — user must approve.

Full detection thresholds and rules:
[`references/ci-fix-squash.md`](references/ci-fix-squash.md).

---

## Post-Completion

Invoke `wk-learn commit`.
