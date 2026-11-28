---
name: wk-renovate
description: >-
  Use when handling open Dependabot dependency-upgrade PRs ("gh-deps").
  Exactly one open → approve and merge it once CI is green. Several open →
  apply their upgrades on a single branch, gate on a green build and CI,
  open one combined PR whose `Closes #N` lines auto-close the originals on
  merge, and close stragglers after.
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
  version: "2026.11.28-052600"
  model:
    openai: gpt-5.6-terra
    google: gemini-2.5-flash
---

# Renovate — Batch Dependabot PRs

Land every open Dependabot PR in the current repo: a lone PR merges as-is; several combine into a single
dependency-update PR — one branch, one review, one merge. Triggers: `/wk-renovate`, "gh-deps", "dependency upgrade
PRs", "combine dependabot PRs", "batch dependency updates", "merge all dependabot".

## Step 1: Discover Dependabot PRs

List all open PRs authored by Dependabot:

```bash
gh pr list --author "app/dependabot" --state open --json number,title,headRefName,body --limit 100
```

- Zero results → report "no open Dependabot PRs" and stop.
- Display a numbered summary table: PR number, title, package, version bump. Extract the dependency name and version
  range from each PR title/body.
- Count ≥ 2 → **pause for confirmation** before Step 2: ask the user to confirm or exclude packages (e.g., "exclude 3,
  7" or "proceed"); call out major-version bumps explicitly in the table (most likely to break). Excluded PRs are
  skipped in Steps 2–5 and omitted from the combined PR. Exclusions leave exactly one → Step 1.5 single path.
- Count = 1 → Step 1.5; no confirmation pause (invoking the skill on a lone PR is the merge directive).

## Step 1.5: Single PR — approve and merge

Exactly one open Dependabot PR → land it directly; skip Steps 2–7 (no combined branch).

- Re-query state: `gh pr view <N> --json state,mergeable,headRefOid,statusCheckRollup,files`. Not `OPEN` → stop;
  `CONFLICTING` → comment `@dependabot rebase` via [wk-gh](../gh/README.md) and stop (Dependabot rebases async).
- CI not green on `headRefOid` → watch it (`gh pr checks <N> --watch --fail-fast`); red → report the failing check and
  stop. Never approve a red PR; never push fixes onto Dependabot's branch (Dependabot force-pushes over it).
- Run the Step 4 major-version audit against the PR's lockfile diff (`gh pr diff <N>`). Any major (up or down, direct
  or transitive) or non-manifest file in `files` → invoke
  [wk-adversarial-review](../adversarial-review/README.md) first; else record the waiver "minor/patch dependency-only
  update, adversarial review skipped" for `wk-pr-merge` Step 5.5.
- Approve, then merge via [wk-pr-merge](../pr-merge/README.md) (never raw `gh pr merge`):

```bash
gh pr review <N> --approve --body "Dependency-only update; CI green."
```

- Approval rejected (`Can not approve your own pull request`, or repo requires a non-author) → report and stop; never
  merge on a missing approval.

## Step 2: Create a Combined Branch

```bash
git fetch origin
git checkout -b dependabot/combined-updates origin/main
```

Branch name: `dependabot/combined-updates`, or `dependabot/combined-updates-<YYYYMMDD>` if the branch already exists.

## Step 3: Apply Each Upgrade

- Cherry-pick each Dependabot PR's commit(s) for its manifest changes, keeping one commit per upgrade.
- **HARD RULE: land only the advertised bumps — never take a Dependabot lockfile wholesale, clean pick or conflict.**
  - Drop the picked lockfile (`git checkout HEAD -- <lockfile>`: the combined branch's pre-pick state), then re-resolve
    scoped to the PR's named packages (bundler: `bundle lock --conservative --update <names>`; cargo:
    `cargo update -p <name> --precise <version>`).
  - Pin each named package to its exact advertised version; a scoped update resolves to the newest release and
    overshoots Dependabot's target (bundler: edit the lock line, rerun `bundle install` to validate).
  - Diff the lockfile vs base: only the named packages and companions their exact pins require may move (versions or
    new platform entries). Report each transitive bump Dependabot carried that the scoped resolve does not need, and
    leave it for a later run.
  - Bundler: drop unsuffixed native-gem entries (`<gem> (x.y.z)` with no platform) when `PLATFORMS` names only
    arch/OS triples that already carry precompiled entries. (Dependabot resolves on the generic `ruby` platform; a
    scoped re-resolve never adds them.)
  - Why: a grouped PR's lockfile can carry transitive majors and platform entries its title and body never name, and
    the Step 1 confirmation covers only the named bumps; Step 4's audit catches them only after they landed.
- Regenerating inside a container (`devcontainer exec`, `docker compose exec`) → reproduce the provisioning script's
  registry-credential export in the same exec shell (re-derive it from that script; never paste the secret literal
  into the command). Why: a lifecycle script's `export` dies with its shell, so container creation installs fine while
  every later exec session fails registry auth.
- Track which PRs applied cleanly and which conflicted. Cherry-pick fails irrecoverably for a PR → skip it, log it,
  continue with the rest.

```bash
for branch in <dependabot_branches>; do
  git cherry-pick --no-commit "origin/$branch" || true  # a lockfile conflict is resolved below
  git checkout HEAD -- <lockfile>                       # drop Dependabot's lockfile, keep prior picks
  <scoped_update <named_packages>>                      # then pin each to its advertised version
  <package_manager_install>
  git add <manifest> <lockfile>
  git commit -C "origin/$branch"
done
```

Detect the package manager from repo root:

| Signal | Manager | Install / consistency check |
|--------|---------|------------|
| `package-lock.json` | npm | `npm install` |
| `yarn.lock` | yarn | `yarn install` |
| `pnpm-lock.yaml` | pnpm | `pnpm install` |
| `Gemfile.lock` | bundler | `bundle install` |
| `Cargo.lock` | cargo | `cargo fetch --locked` (never bare `cargo update`: it bumps everything) |
| `poetry.lock` | poetry | `poetry check --lock` |
| `requirements.txt` | pip | — (no lockfile regen) |

## Step 4: Verify the Combined State

- Run the install command for the detected package manager to confirm the lockfile is consistent.
- **Regenerate vendored copies a bump invalidates.** Per bumped package: read the original Dependabot PR's failing CI
  log first (it names the needed regeneration), then grep the repo for vendored copies (`vendor/<package>` dirs, files
  whose header names it). Found → run the package's own init/regenerate command, confirm its validate command passes,
  and commit the output with the bump. (Dependabot rewrites only the lockfile; a validator that compares a vendored
  copy to the installed version turns CI red.)
- **Build and test gate the PR.** Run the repo's build and test commands (`npm run build` + `npm test`,
  `bundle exec rake`, `cargo build` + `cargo test`). Red → bisect by dropping bumps one at a time to name the breaking
  upgrade; fix it or exclude that PR (it stays open, no `Closes` line), then rerun until green.
- Red gate → rerun it on base (`origin/main` and its lockfile) before blaming a bump; red there too → pre-existing,
  not the update's.
- Deterministic red in a container → before blaming a bump, list forwarded config-override var **names** (compare
  `env | cut -d= -f1` against the compose `environment:` block; never print values) and rerun with them unset; green
  unset → environment-induced, not the update's. Why: host vars the compose file forwards override the test-env config a
  spec reads, and the base control reproduces the same red in the same env.
- **HARD RULE: audit every major-version change — up or down, direct or transitive; a green suite is not evidence of
  safety.**
  - Diff each lockfile against base (`git diff origin/main...HEAD -- <lockfile>`); list every package whose major
    version changed, including transitive deps that no Dependabot PR title names (a grouped patch bump can pull one in).
  - **Important:** a major *downgrade* is an audited major too — a bumped package that pins a dependency to an older
    major rolls it back with no PR naming it.
  - Per major: read the changelog across the whole version span for breaking changes **and default-behavior changes**;
    check the app's use of changed APIs and of defaults it relies on implicitly; record the verdict in the PR body's
    major-bump audit section. A pre-1.0 minor bump (`0.x` → `0.y`) is a major.
  - **Per default-behavior change: grep every construction site of the changed type or builder across the whole
    workspace** (every package, crate, and binary — not only the one being edited); list each in the audit section with
    its fix or justification. Network-client defaults (retries, timeouts, endpoint parsing) → time a run on base vs
    head with the endpoint unreachable, then with an invalid endpoint value. (Fixing only the touched caller leaves its
    siblings regressed, and no test runs against an unreachable or malformed endpoint.)
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

Step 4 found a major → run Step 6's adversarial review first. Push the branch, then open the PR **as a draft** via
[wk-pr](../pr/README.md) with the body from [`references/pr-body-template.md`](references/pr-body-template.md):

```bash
git push -u origin dependabot/combined-updates
```

- **CI gates ready.** Watch checks on the pushed SHA (`gh pr checks <combined> --watch --fail-fast`; Buildkite →
  [wk-buildkite](../buildkite/README.md)). Red → `wk-workflow` Phase 6 fix loop (max 3 attempts); mark ready only when
  every required check is green. (Most CI triggers on the PR, so the draft is how CI runs before review.)
- **One closing keyword per PR, one per line:** `Closes #NNN` per line — never `Closes #NNN, #MMM` (GitHub links only
  the number directly after a keyword; the rest stay open). `Closes` auto-closes pull requests as well as issues on
  merge (field-verified). Only PRs actually applied get a line; Step 7 closes stragglers.

## Step 6: Skip Optional Gates

- **Automated external review:** skip for dependency-only updates.
- **Adversarial review:** run when Step 4 found any major-version change (up or down, direct or transitive) — never
  skip it then. **Run it before the push (latest: while the PR is still draft) and record the verdict in the body.**
  (A user can enable auto-merge on the draft; it merges on green CI before any post-ready gate fires.) Otherwise
  skip unless the combined diff contains non-lockfile, non-manifest code changes (e.g., a Dependabot PR that patches
  application code) — pure minor/patch bumps waste review time on lockfile diffs. Detect
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
