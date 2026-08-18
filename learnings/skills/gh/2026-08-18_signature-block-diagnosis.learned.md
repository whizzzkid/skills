---
skill: wk-gh
date: 2026-08-18
type: gap
severity: medium
verified-against-source: yes
---

A PR merge blocked with "the base branch policy prohibits the merge" (`mergeable_state: blocked`, all required status checks green, review/thread requirements satisfied) can be caused by a `required_signatures` branch/ruleset policy failing on ANY unsigned commit in the PR's full commit range — not just the head commit.

**What happened:** Every other blocker was ruled out one by one (merge method, approval count, thread resolution, strict-up-to-date, required status checks all `success`) before finding the actual cause: one commit partway through the branch's history — introduced by a `git merge origin/<branch>` that pulled in a CI bot's direct push — was unsigned, while the head commit and every other commit verified fine.

**Root cause:** Confirmed via `gh api repos/{owner}/{repo}/pulls/{n}/commits --jq '.[] | {sha, verified: .commit.verification.verified, reason: .commit.verification.reason}'`, which showed `reason: "unsigned"` on exactly one commit in the middle of the range while `gh api .../commits/{head_sha}` alone showed the head as `verified: true`. A `required_signatures` ruleset enforces signing across the whole commit range being merged, so checking only the head commit's verification status misses a mid-history offender introduced by a merge from a branch with unsigned pushes (e.g. a CI/automation bot that pushes directly without signing).

**Suggested fix:** When diagnosing a `mergeable_state: blocked` PR and a `required_signatures` rule is active in the applicable ruleset, check signature verification across the FULL commit range (`gh api repos/{owner}/{repo}/pulls/{n}/commits --jq '...verification...'`), not just the head commit, before ruling the signing policy out as a cause.
