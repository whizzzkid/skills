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
metadata:
  author: whizzzkid
  version: '2026.05.01-080507'
  model:
    openai: gpt-4.1-mini
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-2
---

# Commit

Git commit and push workflow that enforces conventional commits with emoji,
signed commits, and safe push behavior.

## Commit Message Format

Use conventional commits with an emoji after the colon. The emoji is REQUIRED.

**Format:** `<action>(optional scope): <emoji> work-done`

### Primary action emojis

Pick the emoji that matches the conventional-commit action:

| Action | Emoji | Example |
|--------|-------|---------|
| `feat` | ✨ | `feat(auth): ✨ add OAuth2 login` |
| `fix` | 🐛 | `fix(parser): 🐛 handle empty input` |
| `refactor` | ♻️ | `refactor(api): ♻️ extract middleware` |
| `docs` | 📝 | `docs(readme): 📝 update install guide` |
| `test` | 🧪 | `test(auth): 🧪 add token expiry tests` |
| `chore` | 🔧 | `chore(config): 🔧 tune lefthook timeouts` |
| `chore` | 🗑️ | `chore: 🗑️ remove dead code` |
| `ci` | 👷 | `ci(deploy): 👷 add staging pipeline` |
| `revert` | ⏪ | `revert(api): ⏪ revert middleware extraction` |
| `perf` | ⚡ | `perf(query): ⚡ index hot lookup column` |
| `style` | 🎨 | `style(ui): 🎨 align card padding` |
| `build` | 🏗️ | `build(deps): 🏗️ lock new dep tree` |

### Classifier / modifier emojis

When an action emoji alone underspecifies the intent, append one or more
classifier emojis after it. Classifiers carry signal that future readers
(and `git log`-grep) can scan without parsing the message body.

| Emoji | Meaning | Example |
|-------|---------|---------|
| 🔧 | Tuning configs (in-tool knobs, thresholds) | `chore(ci): 🔧 raise {tool} timeout to 60s` |
| 📌 | Version pinned (was unpinned / floating) | `chore(deps): 📌 pin {dep} to {version}` |
| ⬆️ | Version bump (upgrade) | `chore(deps): ⬆️ bump rust 1.93 → 1.94` |
| ⬇️ | Version downgrade | `fix(ci): ⬇️ downgrade {dep} 0.24 → 0.23` |
| 🦾 | Agentic tool strengthening (skill / hook / agent capability) | `feat(skill): 🦾 add idempotency gate to wk-goodmorning` |
| 🛡️ | Adding guardrails (validation, gate, policy enforcement) | `feat(commit): 🛡️ enforce PR sync after push` |
| 🔒 | Security fix or hardening | `fix(auth): 🔒 reject unsigned tokens` |
| 🔥 | Removed code / files / features | `refactor: 🔥 drop deprecated v1 routes` |
| 🚨 | Fix lint / type / static-analysis warning | `fix(lint): 🚨 resolve clippy warnings` |
| 💚 | Fix failing CI | `fix(ci): 💚 install {tool} directly` |
| 🚧 | Work-in-progress (use sparingly; prefer drafts) | `feat(parser): 🚧 partial AST walker` |
| 🩹 | Small non-critical fix | `fix(ui): 🩹 trim trailing whitespace` |
| ♿ | Accessibility improvement | `feat(ui): ♿ add ARIA labels to nav` |
| 🌐 | Internationalization / localization | `feat(i18n): 🌐 add fr-CA translations` |
| 🚸 | UX improvement | `feat(ux): 🚸 friendlier error copy on form submit` |
| 🚀 | Deploy / release-related | `chore(release): 🚀 cut v2026.04.27` |
| ⏱️ | Performance — latency-specific | `perf(api): ⏱️ cache hot endpoint` |
| 🔐 | Touching secrets / keys / credentials | `chore(env): 🔐 rotate signing key` |
| 🛞 | Re-inventing the wheel — flag for review | `feat(util): 🛞 custom retry helper (lib X already does this)` |
| 🧪 | Test-only commit (paired with `test` action) | `test(auth): 🧪 cover token expiry` |
| 🎨 | Readability / code-as-art polish | `refactor(parser): 🎨 rename for clarity` |
| 🤖 | Fallback when no other emoji fits | `chore: 🤖 mixed cleanup across modules` |

**Exactly one emoji per commit subject. No stacking.**

Pick the single most specific emoji that names the change. If a primary
action emoji and a classifier both fit, **use the classifier** — it
carries more signal (`📌` beats `🔧` for a version pin; `⬇️` beats
`fix`'s 🐛 for a version downgrade). If two classifiers both seem
relevant, pick the one a future reader would `grep` for first.

**Fallback when no emoji fits: 🤖.** When a change genuinely defies
classification (mixed-bag commit, agent-driven mechanical change with
no single observable shape, "miscellaneous"), use 🤖 rather than
stacking multiple emojis or picking a poor fit. 🤖 is also the right
choice for fully agent-authored commits where no human curated the
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

Co-Authored-By: Agent Name <noreply@example.com>
EOF
)"
```

## Commit Signing

All commits MUST be signed. Never use `--no-gpg-sign`, `-n`, or
`git -c commit.gpgsign=false`.

**On signing failure** (errors like `gpg failed to sign the data`,
`Couldn't get agent socket`, `failed to write commit object`):

1. **Stop immediately.** Do not retry without signing.
2. Tell the user: "Commit signing failed. Please check your GPG/SSH agent
   configuration and try again."
3. Do not attempt any workaround that disables signing.

## Pushing

**Push after every commit unless the user has explicitly said not to.**
A commit without a push leaves work invisible to the rest of the team
and easy to lose. The push is not a separate step the user must
request — it is the tail of the commit sequence.

If something would block the push (branch protection, no upstream
branch, rejection), report it explicitly to the user. Never silently
skip the push.

Always use regular `git push`. Never use `--force` or `--force-with-lease`
unless:

- The user explicitly asks for a force push
- Commits were rewritten (rebase/amend) and the branch was already pushed

### Mise-managed repos

If the project uses mise (has `.mise.toml` or `.tool-versions`), activate
mise before pushing so that git hooks (lefthook, husky, etc.) can find
mise-managed binaries:

```bash
eval "$(mise activate bash)" && git push
```

Without activation, Bash tool sessions don't inherit the user's interactive
shell, and hooks fail with "command not found" (exit 127) for tools like
`lychee`, `shellcheck`, `bats`, etc.

### Hook and verify rules

Never use `--no-verify` when committing or pushing. If a hook is failing,
stop and ask the user to run the command manually.

If a regular push is rejected, tell the user and ask how to proceed rather
than automatically force-pushing.

## Post-Push: PR Sync (HARD RULE)

**After every successful push to a branch that has an open PR, the PR
title and description MUST be re-checked against the post-push branch
state and updated if they have drifted.** No exceptions.

Drift signals to a reviewer that the agent shipped without re-reading
its own work. The PR is the source of truth for everyone except the
author — leaving it stale silently changes what reviewers approve.

### Step 1: Detect whether a PR exists

After `git push` returns success:

```bash
gh pr view --json number,title,body,headRefName,state 2>/dev/null
```

- Exit code non-zero or `state != OPEN` → no open PR; skip the rest of
  this section.
- Otherwise capture `number`, `title`, `body` for comparison.

### Step 2: Check for drift

Compare the PR's current title and body against the branch's
post-push state:

| Drift signal | Example |
|---|---|
| Title no longer matches primary intent | scope flipped feat→fix; version pin landed but title still says "upgrade" |
| Body lists commits/behaviors that no longer exist | removed commits, reverted decisions still described as live |
| Test plan / Closes section is now wrong | steps reference removed code; linked issue closed by a different PR |
| Body cites a version or config value the push changed | dep version in body doesn't match lockfile |

A clean push that only adds tests/docs aligned with the existing
description is **not** drift.

### Step 3: Update on drift

If drift is detected, update the PR before returning control:

```bash
gh pr edit <number> --title "<new-title>" \
  --body "$(cat <<'EOF'
<refreshed body>
EOF
)"
```

Rules for the refresh:

- Preserve any `Closes #N` / `Fixes #N` / `Refs #N` annotations unless
  they are now wrong.
- Preserve human-authored sections (reviewer notes, test plan checks
  the user added). Do not overwrite review checkboxes a human ticked.
- Reflect the **current** set of commits and the **current** behavior —
  not the historical narrative of how the branch evolved.
- Keep the title under ~70 chars; details belong in the body.

If unsure whether a section is human-authored vs agent-authored, ask
the user before overwriting it. Better to ask once than to clobber a
hand-edited test plan.

### Step 4: Report

Tell the user explicitly that the PR was synced (or that no drift was
found):

> "Pushed to `<branch>`. PR #<N> title/body updated to reflect the new
> commits."

Or:

> "Pushed to `<branch>`. PR #<N> already in sync — no edit needed."

Silence after a push that touched an open PR is itself a violation of
this rule.

## Post-CI-Fix Squash Offer

After the CI fix loop (`wk-workflow` Phase 6) exits green, before
marking the PR ready, check whether the branch has a long tail of
small `fix(ci):` commits that would be more readable as one.

**Detection:** count commits on the branch ahead of the base whose
message matches `^fix(\(ci\))?:`. If the count is ≥3 **and** the net
diff across those commits is small (<50 lines, single config file or a
handful of related ones), offer to squash them into a single commit
that names the actual change that shipped:

```bash
N=$(git log --oneline "$(git merge-base HEAD main)..HEAD" \
    --grep '^fix(\(ci\))\?:' | wc -l | tr -d ' ')
LINES=$(git diff "$(git merge-base HEAD main)..HEAD" \
    -- $(git log --name-only --pretty=format: "$(git merge-base HEAD main)..HEAD" \
    --grep '^fix(\(ci\))\?:' | sort -u) | wc -l | tr -d ' ')
```

If `N >= 3 && LINES < 50`, ask:

> "The branch has {N} `fix(ci):` commits whose net diff is {LINES}
> lines. Want me to squash them into a single
> `fix(ci): <emoji> <what-actually-shipped>` commit before marking the
> PR ready? (a) yes  (b) keep separate"

**Rules:**

- **Do not auto-squash.** This is destructive — the user must approve.
- **Do not squash across user-authored commits.** Only squash the
  agent's own back-to-back CI fix commits. If a user commit sits in
  the middle, leave the chain intact.
- **Force-push is required after squash.** Confirm the user accepts
  the force-push before rewriting history on a pushed branch.
- **Use the new subject to name the actual fix**, not the journey.
  "fix(ci): ⬇️ downgrade and pin {dep} {version}" beats "squashed CI
  fix attempts."

If the user declines or the thresholds aren't met, leave history alone.

## Quick Reference

| Trigger | Behavior |
|---------|----------|
| "commit this" | Stage relevant files, create signed commit with conventional format |
| "push" | Regular push, ask on rejection |
| Signing failure | Stop, tell user to fix GPG/SSH config |
| Hook failure | Stop, ask user to run manually |
| Push succeeded + open PR exists | Run PR Sync — diff title/body vs branch, `gh pr edit` if drifted |
| Push succeeded + no PR | Skip PR Sync silently |

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument (e.g., `wk-learn commit`).
