---
skill: wk-pr
date: 2026-10-28
type: correction
severity: high
verified-against-source: yes
---

Upstream PR from a fork opened before CI ever ran; upstream CI needed maintainer approval.

**What happened:** The agent pushed a branch to the user's fork and opened the PR straight against the upstream repo.
Upstream's CI workflow reported `action_required` (fork runs need maintainer approval), so the change reached the
maintainer with no CI signal, and defects CI might have caught went straight to their review.

**Root cause:** The skill treats "open PR to the target repo" as the first CI touchpoint. For fork-based OSS
contributions, upstream CI is gated by the maintainer, so the first green run must happen elsewhere.

**Suggested fix:** When the push remote is a fork of the PR target, first open a PR inside the fork (branch → fork's
default branch) so the fork's own Actions run the same workflows; wait for green there, then open the upstream PR.
Detect via `gh repo view --json isFork,parent` on the push remote, and enable Actions on the fork if disabled.
