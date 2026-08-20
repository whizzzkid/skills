---
name: wk-renovate
description: >-
  Use when combining open Dependabot PRs into a single batched dependency
  update PR. Finds all open Dependabot PRs in the current repo, applies
  their upgrades on a single branch, creates a combined PR with
  Supersedes annotations, and closes the originals after merge.
user-invocable: true
model-invocable: true
model: sonnet
effort: medium
license: MIT
group: pull-request
env-vars:
  - GITHUB_ORG
  - GH_TOKEN
allowed-tools:
  - Bash
  - Bash(gh:*)
  - Bash(git:*)
  - Bash(npm:*)
  - Bash(yarn:*)
  - Bash(bundle:*)
  - Bash(pip:*)
  - Bash(cargo:*)
  - Read
  - Edit
  - Skill
  - "mcp__claude_ai_Github-*__*"
metadata:
  author: whizzzkid
  version: "2026.08.20-231910"
  model:
    openai: gpt-5.6-terra
    google: gemini-2.5-flash
---

# Renovate — Batch Dependabot PRs

Combine all open Dependabot PRs in the current repo into a single
dependency-update PR. One branch, one review, one merge.

## When to Use

- Open Dependabot PRs are piling up and you want a single combined update.
- `/wk-renovate` invoked directly.
- "combine dependabot PRs", "batch dependency updates", "merge all dependabot".

## Step 1: Discover Dependabot PRs

List all open PRs authored by Dependabot:

```bash
gh pr list --author "app/dependabot" --state open --json number,title,headRefName,body --limit 100
```

- Zero results → report "no open Dependabot PRs" and stop.
- Display a numbered summary table: PR number, title, package, version bump.
- Extract the dependency name and version range from each PR title/body.
- **Pause for confirmation** before proceeding to Step 2.
  - Ask the user to confirm or exclude packages (e.g., "exclude 3, 7" or "proceed").
  - Major-version bumps → call out explicitly in the table; these are most likely to break.
  - Excluded PRs are skipped in Steps 2–5 and omitted from the combined PR.

## Step 2: Create a Combined Branch

```bash
git fetch origin
git checkout -b dependabot/combined-updates origin/main
```

- Branch name: `dependabot/combined-updates` (or
  `dependabot/combined-updates-<YYYYMMDD>` if the branch already exists).

## Step 3: Apply Each Upgrade

For each Dependabot PR, cherry-pick or merge its changes:

- Prefer cherry-picking the Dependabot commit(s) to keep the upgrade atomic.
- On conflict: attempt auto-resolution of lockfile conflicts by re-running
  the package manager's install/lock command.
- Track which PRs applied cleanly and which conflicted.

```bash
for branch in <dependabot_branches>; do
  git cherry-pick origin/$branch || {
    # Lockfile conflict — resolve by regenerating
    <package_manager_install>
    git add <lockfile>
    git cherry-pick --continue
  }
done
```

### Package manager detection

Detect from repo root and regenerate lockfiles accordingly:

| Signal | Manager | Regenerate |
|--------|---------|------------|
| `package-lock.json` | npm | `npm install` |
| `yarn.lock` | yarn | `yarn install` |
| `pnpm-lock.yaml` | pnpm | `pnpm install` |
| `Gemfile.lock` | bundler | `bundle install` |
| `Cargo.lock` | cargo | `cargo update` |
| `poetry.lock` | poetry | `poetry lock` |
| `requirements.txt` | pip | — (no lockfile regen) |

If cherry-pick fails irrecoverably for a PR, skip it, log it, and continue
with the rest.

## Step 4: Verify the Combined State

- Run the install command for the detected package manager to confirm the
  lockfile is consistent.
- If a test command is obvious (`npm test`, `bundle exec rake`, `cargo test`),
  run it. On failure, report which upgrade likely broke it but do not block —
  the CI on the PR will catch it.

## Step 5: Create the Combined PR

Push the branch and open a PR:

```bash
git push -u origin dependabot/combined-updates
```

### PR body format

```markdown
## Combined Dependency Updates

Batches the following Dependabot PRs into a single update:

| PR | Package | Version |
|----|---------|---------|
| #<N> | <package> | <old> → <new> |
...

### Superseded PRs
Closes #<N1>, #<N2>, #<N3>, ...

### Post-merge cleanup
GitHub auto-closes PRs referenced by `Closes #N` on merge.
Verify closed state; if any remain open: `gh pr close <N> --delete-branch --comment "Superseded by #<this_PR>"`
Or invoke `/wk-renovate cleanup` to handle stragglers.
```

### `Closes #N` auto-closes PRs too

GitHub's `Closes` keyword auto-closes both issues **and** pull requests on
merge (field-verified). Use `Closes #N` in the PR body for each superseded
Dependabot PR. Step 7 handles any that remain open as stragglers.

## Step 6: Skip Optional Gates

- **Automated external review:** skip for dependency-only updates.
- **Adversarial review:** skip unless the combined diff contains non-lockfile,
  non-manifest code changes (e.g., a Dependabot PR that patches application
  code). Detect:

```bash
git diff origin/main...HEAD --name-only | grep -vE '(package\.json|package-lock\.json|yarn\.lock|pnpm-lock\.yaml|Gemfile|Gemfile\.lock|Cargo\.toml|Cargo\.lock|requirements.*\.txt|poetry\.lock|\.github/|go\.sum|go\.mod)' | head -5
```

Non-empty → invoke [wk-adversarial-review](../adversarial-review/README.md).
Empty → skip with a note: "dependency-only update, adversarial review skipped."

## Step 7: Post-Merge Cleanup (`/wk-renovate cleanup`)

After the combined PR merges, `Closes #N` keywords auto-close the referenced
PRs. This step handles stragglers:

```bash
for pr in <superseded_pr_numbers>; do
  gh pr close "$pr" --delete-branch \
    --comment "Superseded by #<combined_pr> — dependencies updated in the combined PR." 2>/dev/null
done
```

- Parse superseded PR numbers from the merged PR body (`Closes #...`).
- Already-closed PRs are expected (auto-closed by `Closes`) — skip gracefully.

## Quick Reference

| Trigger | Behavior |
|---------|----------|
| `/wk-renovate` | Discover → combine → PR (Steps 1–6) |
| `/wk-renovate cleanup` | Close superseded PRs after merge (Step 7) |

## Common Mistakes

- **Assuming `Closes #N` only works for issues** — it auto-closes PRs too;
  use it in the combined PR body for each superseded Dependabot PR.
- **Cherry-picking lockfile conflicts without regenerating** — always re-run
  the package manager to produce a consistent lockfile.
- **Running adversarial review on pure dependency bumps** — wastes time on
  lockfile diffs with no semantic code changes.

## Requirements

- `gh` CLI authenticated with repo access
- `$GITHUB_ORG` set (via [wk-gh](../gh/README.md))
- Package manager available for lockfile regeneration

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument
(e.g., `wk-learn renovate`).
