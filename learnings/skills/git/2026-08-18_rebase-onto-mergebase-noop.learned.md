---
skill: wk-git
date: 2026-08-18
type: surprise
severity: medium
verified-against-source: yes
---

`git rebase <base>` (even with `--rebase-merges`) silently no-ops, keeping the original commit SHAs, when `<base>` already equals the branch's actual merge-base.

**What happened:** Needed to re-sign a commit that was unsigned partway through a branch's history (it had been merged in from a remote push). Ran `git rebase --rebase-merges <merge-base>` expecting it to recreate every commit from that point forward under the local signing key. The command reported success, but `HEAD` and every commit SHA in the range were byte-identical to before — nothing was recreated, so the unsigned commit stayed unsigned.

**Root cause:** Verified by comparing `git rev-parse HEAD` before and after the rebase (identical), and by rerunning with `--force-rebase` which then produced new SHAs and fixed the signature. Git treats a rebase target equal to the current merge-base as "already up to date" and takes a fast-path no-op, even under `--rebase-merges`, because nothing in the resulting topology would differ from a naive read — but this misses the case where the caller wants to recreate commit objects for a side effect (re-signing, re-authoring) rather than to change the tree/topology.

**Suggested fix:** When rebasing specifically to force-recreate commits (re-signing, refreshing commit metadata) rather than to move a branch onto a new base, always pass `--force-rebase` (`-f`). Don't rely on `git rev-list --left-right --count` or "no conflicts reported" as proof the rebase did anything — check that the resulting HEAD SHA actually changed, and that the specific commit(s) needing recreation show a new signature/raw `gpgsig` header, before declaring the fix applied.
