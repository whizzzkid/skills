---
class: principle
---

# Resolving a squash-landed parent in place, when restarting is not worth it

**Rule** — Merge strategy with a parent that already squash-landed: take
`--theirs` for files the squashed parent fully supersedes, hand-merge files both
histories added to, then gate on the full suite. In a **merge**, `--theirs` is the
incoming base and `--ours` is the PR branch — inverted, this discards the branch's
own work. `--onto` remains preferred whenever the replay has not started.

**Why** — The skill already predicted these add/add conflicts and prescribed
`--onto`, but every path assumed the replay could be restarted. A run already deep
into conflict resolution had no sanctioned way to finish, so the resolution was
improvised. The ours/theirs orientation is spelled out because it inverts between
merge and rebase, and guessing wrong silently deletes the branch's work — the one
mistake here that is not recoverable from the conflict state.

**Where** — `skills/pr-update/SKILL.md` → *Merged-parent branches: rebase `--onto`*,
as the bullet after the parent-tip lookup.

## The detection lesson from the same scenario was already covered

The source's corrective lesson — detect the independently-merged-parent pattern
*proactively* and route to `--onto` rather than discovering it through conflicts —
is already installed:

- The reactive form (`Detect: unexpected add/add conflicts on files this branch
  never touched, right after a parent branch merged`) has existed since 2026-05-29.
- The proactive form (comparing the branch's pre-fork commits against the base's
  merged PRs, setting `STACKED_PARENT_DETECTED=true`, and routing Stage 2 to
  `rebase --onto`) plus its strategy-table row landed 2026-08-12.

**No escalation notch.** The proactive text landed one day *after* the reporting
session, so it never steered the failing run. This is `already-covered
(unshipped)`, and escalating would punish a rule for a run it could not reach.
