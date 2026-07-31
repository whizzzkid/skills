---
class: principle
date: 2026-07-29
severity: medium
---

# Reconcile concurrent merges before mutation

**Rule:** Re-fetch pull-request state and head OID immediately before every
post-fix push or merge. If the PR is already merged, skip the mutation and
continue post-merge processing. After an interrupted command, verify PR state
and the remote head before retrying.

**Why:** Another actor can merge while a fix is being prepared. A command
interruption can also occur after its remote side effect, so retrying or
reporting cancellation from local control flow alone can push obsolete work or
misstate repository state.

**Where:** Merge workflows after any CI or review repair, and every recovery
path from an interrupted push or merge.
