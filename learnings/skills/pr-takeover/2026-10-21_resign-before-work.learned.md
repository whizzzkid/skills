---
skill: wk-pr-takeover
date: 2026-10-21
type: gap
severity: high
verified-against-source: yes
---

Validate every inherited commit's signature before starting takeover work, and re-sign the unsigned ones first.

**What happened:** The original author was an automation bot, and its commit was unsigned. The takeover added signed commits on top, and CI, review and thread resolution all went green. Merge was still blocked by the required-signatures rule. Re-signing then meant rewriting history under finished work (rebase, force-with-lease push), which invalidated the SHAs cited in the PR body and thread replies.

**Root cause:** The takeover steps (fetch context, check out, establish co-authorship) never check `commit.verification` on the inherited commits. Branch protection that requires signed commits only shows up at merge time.

**Suggested fix:** Add a step right after checkout, before any work:
1. `gh api repos/{owner}/{repo}/pulls/{n}/commits --paginate --jq '.[] | select(.commit.verification.verified | not) | .sha'`.
2. If any commit is unverified, rebase the branch's non-merge commits onto the current base with `git rebase --gpg-sign origin/<base>`. This re-signs every commit, preserves authors and drops merge-from-base commits.
3. Confirm a `gpgsig` header on each commit with `git cat-file commit <sha>`. A local `%G?` of `N` can be a false alarm when SSH signing has no `allowedSignersFile`.
4. Push with `--force-with-lease=<branch>:<old-sha>`, then re-check `verified=true` through the API.
5. Only then start fixes, so every SHA you later cite stays stable.
