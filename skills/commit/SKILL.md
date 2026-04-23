---
name: wk:commit
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
  - AskUserQuestion
  # Learning capture (post-completion hook)
  - Write
  - "Bash(mkdir -p:*)"
model: sonnet
effort: low
model-invocable: true
user-invocable: true
license: MIT
metadata:
  author: whizzzkid
  version: '2026.04.23-054649'
  model:
    openai: gpt-4.1-mini
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-1.5
---

# Commit

Git commit and push workflow that enforces conventional commits with emoji,
signed commits, and safe push behavior.

## Commit Message Format

Use conventional commits with an emoji after the colon. The emoji is REQUIRED.

**Format:** `<action>(optional scope): <emoji> work-done`

| Action | Emoji | Example |
|--------|-------|---------|
| `feat` | ✨ | `feat(auth): ✨ add OAuth2 login` |
| `fix` | 🐛 | `fix(parser): 🐛 handle empty input` |
| `refactor` | ♻️ | `refactor(api): ♻️ extract middleware` |
| `docs` | 📝 | `docs(readme): 📝 update install guide` |
| `test` | 🧪 | `test(auth): 🧪 add token expiry tests` |
| `chore` | 🔧 | `chore(deps): 🔧 bump dependencies` |
| `chore` | 🗑️ | `chore: 🗑️ remove dead code` |
| `ci` | 🏗️ | `ci(deploy): 🏗️ add staging pipeline` |

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

## Quick Reference

| Trigger | Behavior |
|---------|----------|
| "commit this" | Stage relevant files, create signed commit with conventional format |
| "push" | Regular push, ask on rejection |
| Signing failure | Stop, tell user to fix GPG/SSH config |
| Hook failure | Stop, ask user to run manually |

---

## Post-Completion: Learning Capture

**After this skill finishes its primary work**, capture what happened
before returning control.

### Check environment

```bash
test -n "$WK_SKILLS_HOME" && echo "OK: $WK_SKILLS_HOME" || echo "MISSING"
```

If `$WK_SKILLS_HOME` is not set, ask the user:

> "`$WK_SKILLS_HOME` is not set. Please add
> `export WK_SKILLS_HOME=/path/to/skills` to your shell profile and
> restart your terminal."

**Stop here if the variable is missing.** Do not guess or use a fallback.

### Reflect

Review what happened during this skill's execution:

1. **What went wrong?** — Errors, wrong assumptions, user corrections,
   API failures, unexpected behavior
2. **What was missing?** — Steps the skill should have included, edge
   cases not covered, tools not available
3. **What worked well?** — Approaches that succeeded, patterns worth
   reinforcing
4. **What surprised you?** — Non-obvious discoveries that future runs
   should know about

If ALL lenses are empty (routine execution, nothing notable), **skip
writing** — not every run produces a learning.

### Write the learning

```bash
mkdir -p "$WK_SKILLS_HOME/learnings/skills/commit"
```

Write to
`$WK_SKILLS_HOME/learnings/skills/commit/<YYYY-MM-DD>_<learning-slug>.md`:

```markdown
---
skill: wk:commit
date: <YYYY-MM-DD>
type: <correction | gap | pattern | surprise>
severity: <low | medium | high>
---

<One-line summary>

**What happened:** <What the skill did or failed to do>

**Root cause:** <Why — missing instruction, wrong assumption, edge case>

**Suggested fix:** <What should change in the skill to prevent this>
```

Use a 2-4 word kebab-case slug (e.g., `missing-null-check`,
`wrong-api-endpoint`, `good-parallel-pattern`).

### Signal for distillation

After writing, note:

> "📝 Learning captured: `commit/<date>_<slug>.md` — distill with
> `wk:sharpen` when ready."

Learnings accumulate in `$WK_SKILLS_HOME/learnings/skills/` and are
batch-distilled into skill improvements via `wk:sharpen`.
