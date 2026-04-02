---
name: wk:commit
description: >-
  Use when creating git commits or pushing code. Enforces conventional commits
  with emoji, commit signing, and safe push behavior. Use for all git commit
  and push operations.
allowed-tools:
  - Bash
  - AskUserQuestion
model:
  anthropic: sonnet
  openai: gpt-4.1-mini
  google: gemini-2.5-flash
  meta: llama-4-scout
  kimi: k2
  qwen: qwen3-30b
  cursor: composer-1.5
disable-model-invocation: false
license: MIT
metadata:
  author: whizzzkid
  version: '1.0.0'
  effort: low
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

Always use regular `git push`. Never use `--force` or `--force-with-lease`
unless:

- The user explicitly asks for a force push
- Commits were rewritten (rebase/amend) and the branch was already pushed

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
