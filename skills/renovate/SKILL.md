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
  version: "2026.10.23-224513"
  model:
    openai: gpt-5.6-terra
    google: gemini-2.5-flash
---

# Renovate — Batch Dependabot PRs

Combine all open Dependabot PRs in the current repo into a single dependency-update PR: one branch, one review, one
merge. Triggers: `/wk-renovate`, "combine dependabot PRs", "batch dependency updates", "merge all dependabot".

## Step 1: Discover Dependabot PRs

List all open PRs authored by Dependabot:

```bash
gh pr list --author "app/dependabot" --state open --json number,title,headRefName,body --limit 100
```

- Zero results → report "no open Dependabot PRs" and stop.
- Display a numbered summary table: PR number, title, package, version bump. Extract the dependency name and version
  range from each PR title/body.
- **Pause for confirmation** before proceeding to Step 2: ask the user to confirm or exclude packages (e.g., "exclude 3,
  7" or "proceed"); call out major-version bumps explicitly in the table (most likely to break). Excluded PRs are
  skipped in Steps 2–5 and omitted from the combined PR.

## Step 2: Create a Combined Branch

```bash
git fetch origin
git checkout -b dependabot/combined-updates origin/main
```

Branch name: `dependabot/combined-updates`, or `dependabot/combined-updates-<YYYYMMDD>` if the branch already exists.

## Step 3: Apply Each Upgrade

- Prefer cherry-picking each Dependabot PR's commit(s) to keep the upgrade atomic.
- On lockfile conflict: always regenerate by re-running the package manager's install/lock command — never cherry-pick a
  lockfile conflict without regenerating.
- Track which PRs applied cleanly and which conflicted. Cherry-pick fails irrecoverably for a PR → skip it, log it,
  continue with the rest.

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

Detect the package manager from repo root:

| Signal | Manager | Regenerate |
|--------|---------|------------|
| `package-lock.json` | npm | `npm install` |
| `yarn.lock` | yarn | `yarn install` |
| `pnpm-lock.yaml` | pnpm | `pnpm install` |
| `Gemfile.lock` | bundler | `bundle install` |
| `Cargo.lock` | cargo | `cargo update` |
| `poetry.lock` | poetry | `poetry lock` |
| `requirements.txt` | pip | — (no lockfile regen) |

## Step 4: Verify the Combined State

- Run the install command for the detected package manager to confirm the lockfile is consistent.
- Test command obvious (`npm test`, `bundle exec rake`, `cargo test`) → run it. On failure, report which upgrade likely
  broke it but do not block — the CI on the PR will catch it.
- Red gate → rerun it on base (`origin/main` and its lockfile) before blaming a bump; red there too → pre-existing,
  not the update's.
- **HARD RULE: audit every major-version change — up or down, direct or transitive; a green suite is not evidence of
  safety.**
  - Diff each lockfile against base (`git diff origin/main...HEAD -- <lockfile>`); list every package whose major
    version changed, including transitive deps that no Dependabot PR title names (a grouped patch bump can pull one in).
  - **Important:** a major *downgrade* is an audited major too — a bumped package that pins a dependency to an older
    major rolls it back with no PR naming it.
  - Per major: read the changelog across the whole version span for breaking changes **and default-behavior changes**;
    check the app's use of changed APIs and of defaults it relies on implicitly; record the verdict in the PR body's
    major-bump audit section.
  - A change reverts a safety-relevant default (stricter parsing, validation, escaping) → set that default explicitly at
    each call site, with a spec that fails against the reverted default first.
  - Why: a transitive major can break an error path no test covers, and a downgrade silently loosens defaults no test
    asserts — only reading upstream changes surfaces either.
- **Regenerate derived artifacts (type stubs, schema annotations) against fresh isolated state, never a shared dev DB.**
  - Point the app at a throwaway DB name via its config env override, migrate it from scratch, regenerate, then compare
    the changed-file list against what CI expects.
  - Scope per-dependency regeneration to the bumped packages only; a full regen sweeps unrelated stale output into the
    diff.
  - Never drop the development DB to get fresh state — a dev-environment drop task can drop the test DB with it.
  - Why: a dev DB volume is shared across worktrees, so it carries other branches' migrations and local output drifts
    from CI.

## Step 5: Create the Combined PR

Push the branch and open a PR with the body from [`references/pr-body-template.md`](references/pr-body-template.md):

```bash
git push -u origin dependabot/combined-updates
```

Use `Closes #N` for each superseded Dependabot PR: GitHub's `Closes` keyword auto-closes both issues **and** pull
requests on merge (field-verified); never assume it only works for issues. Step 7 handles any that remain open as
stragglers.

## Step 6: Skip Optional Gates

- **Automated external review:** skip for dependency-only updates.
- **Adversarial review:** run when Step 4 found any major-version change (up or down, direct or transitive) — never
  skip it then. Otherwise skip unless the combined diff contains non-lockfile, non-manifest code changes (e.g., a
  Dependabot PR that patches application code) — pure minor/patch bumps waste review time on lockfile diffs. Detect
  code changes:

```bash
git diff origin/main...HEAD --name-only | grep -vE '(package\.json|package-lock\.json|yarn\.lock|pnpm-lock\.yaml|Gemfile|Gemfile\.lock|Cargo\.toml|Cargo\.lock|requirements.*\.txt|poetry\.lock|\.github/|go\.sum|go\.mod)' | head -5
```

Non-empty or any major change → invoke [wk-adversarial-review](../adversarial-review/README.md), pointing it at each
major's upstream changes. Empty and no major → skip with a note: "minor/patch dependency-only update, adversarial review
skipped."

## Step 7: Post-Merge Cleanup (`/wk-renovate cleanup`)

After the combined PR merges, `Closes #N` keywords auto-close the referenced PRs; close stragglers:

```bash
for pr in <superseded_pr_numbers>; do
  gh pr close "$pr" --delete-branch \
    --comment "Superseded by #<combined_pr> — dependencies updated in the combined PR." 2>/dev/null
done
```

- Parse superseded PR numbers from the merged PR body (`Closes #...`).
- Already-closed PRs are expected (auto-closed by `Closes`) — skip gracefully.

## Requirements

`gh` CLI authenticated with repo access; `$GITHUB_ORG` set (via [wk-gh](../gh/README.md)); package manager available for
lockfile regeneration.

## Post-Completion

Invoke `wk-learn renovate`.
