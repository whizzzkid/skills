---
skill: wk-workflow
date: 2026-08-14
type: correction
severity: high
verified-against-source: yes
---

Stacked PR creation skipped mandatory workflow phases and missed platform-specific CI gates

**What happened:** Created a 4-PR stack but left all PRs as drafts without running
adversarial review or marking ready, regenerated platform-specific artifacts (store-asset PNGs,
visual baselines) on the Mac host instead of the documented Linux CI container, did not respond
to bot review comments (Copilot) until the user asked, did not use `gh stack` to manage the
chain despite the extension being installed, and did not proactively rebase child PRs after
parent merges — leaving merge conflicts for the user to discover.

**Root cause:** Six distinct failures: (1) The workflow's autonomy rules require `gh pr ready`
and `wk-adversarial-review` before claiming a PR done — skipped in favor of speed. (2) The
project's store-asset and visual-baseline checks run in a pinned Linux container
(`mcr.microsoft.com/playwright:v1.62.0-noble` on `linux/amd64`); Mac host renders different PNG
bytes, so `store:assets:check` and `visual` CI jobs fail on every push that regenerated assets
locally. (3) `gh stack init` was available but not used; manual `--base` setting and rebases were
error-prone. (4) Bot review comments (from automated reviewers) were visible on each PR but not
addressed until the user flagged them. (5) After a parent PR merges, GitHub auto-deletes the
base branch and children become conflicting — the agent should rebase immediately. (6) Running
`deno task ci` on the Mac host does not catch platform-dependent failures; the CI container is
the authoritative gate.

**Suggested fix:** Add to the skill's Phase 5 (PR) section: (a) When `gh stack` is installed,
use `gh stack init` to manage the chain — it handles base-branch updates and rebases
automatically. (b) When the project has platform-pinned CI gates (visual baselines, store-asset
screenshots), regenerate those artifacts inside the documented CI container before every push,
not on the local host. (c) After pushing each PR, poll for bot review comments (Copilot, etc.)
and address them in the same pass as self-review — the workflow's review-comment resolution loop
already mandates this but the trigger was missing for bot-generated threads. (d) After a parent
PR merges, immediately rebase all child branches onto `main` and force-push before the user
notices merge conflicts. (e) Never leave a PR as draft past the point where CI passes — the
workflow requires `gh pr ready` before the adversarial review gate.
