---
class: principle
source: learnings/skills/pr-review/2026-11-23_ownership-claims-need-ruleset.learned.md
date: 2026-11-23
skill: wk-pr-review
---

**Rule** — Confirm a governance/ownership claim ("only X can change Y", "needs X's review") from the effective branch
rules (`pull_request` rule `require_code_owner_review`, `required_approving_review_count`), `codeowners/errors`, and
recent merges' approvers — never from CODEOWNERS syntax alone. Logic that branches on a context field (env var,
event/payload key) is verified against that field's value in a real production run's inputs, not only the code that
sets it.

**Why** — A PR claimed CODEOWNERS made a team the sole gate; the ruleset did not require code-owner review and bot
approvals satisfied the single required review, so the claim was false. A separate "skip unless base is default" branch
read an env var that is always empty on API-triggered CI builds; reasoning about event triggers missed it, reading a
real job's env found it. The claim-verification bullets covered empirical and cited-figure claims, not governance.

**Verified against source** — `GET repos/{o}/{r}/rules/branches/{branch}` returns the effective rules (rc 0, `[]` when
none); `GET repos/{o}/{r}/codeowners/errors` is a documented endpoint (404 when no CODEOWNERS file). API mechanics stay
in `wk-gh`; this fold only routes the claim type there.

**Where** — `SKILL.md` → Phase 1 Claims sub-bullet; Phase 3 context-field paragraph. Same commit relocated the
concurrency harness recipe to `references/concurrency-lock-harness.md` (structural reclaim, rule kept inline).
