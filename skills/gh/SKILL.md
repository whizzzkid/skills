---
name: wk:gh
description: >-
  Activates whenever the agent uses the gh CLI or interacts with GitHub
  PRs, issues, or notifications. Ensures all GitHub operations are scoped
  to the user's organization via $GITHUB_ORG. Prompts the user to set
  the variable if missing.
model-invocable: true
user-invocable: false
model: sonnet
effort: low
license: MIT
metadata:
  author: whizzzkid
  version: '2026.04.22-070656'
  model:
    openai: gpt-4.1-mini
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-1.5
---

# GitHub Organization Scope

Ensures all `gh` CLI and GitHub interactions are scoped to the user's
organization. Activates automatically when the agent is about to run any
`gh` command or interact with GitHub PRs, issues, or notifications.

## Step 1: Check for $GITHUB_ORG

Before running any `gh` command, verify that `$GITHUB_ORG` is set:

```bash
echo "${GITHUB_ORG:?}"
```

### If $GITHUB_ORG is missing or empty

**STOP.** Do not run the `gh` command. Prompt the user:

> "`$GITHUB_ORG` is not set. All GitHub operations are scoped to your
> org to avoid noise from forks and personal repos.
>
> Please set it:
> ```
> export GITHUB_ORG=your-org-name
> ```
>
> Or run `! export GITHUB_ORG=your-org-name` in this session."

**Do not proceed until `$GITHUB_ORG` is set.** Do not guess or infer
the org name from the current repo — it must be explicitly set by the
user.

## Step 2: Scope All Commands

Once `$GITHUB_ORG` is confirmed, apply the org filter to every `gh`
command:

### Search commands

Add `--owner=$GITHUB_ORG` to all `gh search` commands:

```bash
# PRs
gh search prs --owner="$GITHUB_ORG" --review-requested=@me --state=open ...
gh search prs --owner="$GITHUB_ORG" --author=@me --state=open ...

# Issues
gh search issues --owner="$GITHUB_ORG" --assignee=@me --state=open ...
```

### Notifications

Filter notifications to the org:

```bash
gh api notifications --jq ".[] | select(.repository.owner.login == \"$GITHUB_ORG\") | ..."
```

### Issue/PR creation

No special filtering needed — these operate on the current repo. But
if the current repo is not in `$GITHUB_ORG`, warn the user:

```bash
CURRENT_ORG=$(gh repo view --json owner --jq '.owner.login')
if [ "$CURRENT_ORG" != "$GITHUB_ORG" ]; then
  echo "Warning: current repo ($CURRENT_ORG) is not in $GITHUB_ORG"
fi
```

## Exceptions

The org scope is **not applied** when:

- The user explicitly names a different org or repo (e.g., "check
  PRs on `other-org/repo`")
- The user says "all orgs", "everywhere", or "across all repos"
- The command targets the current repo specifically (e.g., `gh pr view`)

In all other cases, default to `$GITHUB_ORG`.

## Quick Reference

| Scenario | Behavior |
|----------|----------|
| `$GITHUB_ORG` set | Add `--owner=$GITHUB_ORG` to search commands |
| `$GITHUB_ORG` missing | Stop and prompt user to set it |
| User names a different org | Use that org instead |
| User says "all orgs" | Skip org filter |
| Current-repo commands | No filter needed |

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
mkdir -p "$WK_SKILLS_HOME/learnings/skills/gh"
```

Write to
`$WK_SKILLS_HOME/learnings/skills/gh/<YYYY-MM-DD>_<learning-slug>.md`:

```markdown
---
skill: wk:gh
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

> "📝 Learning captured: `gh/<date>_<slug>.md` — distill with
> `wk:sharpen` when ready."

Learnings accumulate in `$WK_SKILLS_HOME/learnings/skills/` and are
batch-distilled into skill improvements via `wk:sharpen`.
