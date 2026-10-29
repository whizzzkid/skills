---
class: principle
source: learnings/skills/gh/2026-10-29_thread-replies-first.learned.md
date: 2026-10-29
severity: high
---

# Thread replies first — a pending-review 422 stops and asks, never routes around

**Rule** — On REST `/replies` 422 `one pending review`, stop and ask the user to submit or discard their draft, or
approve adding the replies to it; then reply in every thread. Never react without an in-thread reply; issue comments
carry non-thread findings only. Never submit or delete the draft yourself.

**Why** — The react-plus-one-issue-comment fallback put every answer off-thread, where neither reviewers nor bots see
it in context, and a bare reaction explains nothing. It supersedes the same-day
`2026-10-29_pending-review-blocks-replies` fold, which installed that fallback (not an escalation: the user
corrected the rule's content, so the fold replaces it and carries `**Important:**` as a rewrite of a rule the
user had to correct).

**Where** — `skills/gh/SKILL.md` Step 3; `references/pending-review-mechanics.md`, `github-api-surfaces.md`,
`pending-review-rest-block.md`; `skills/pr-resolve/references/commands.md` pending-review handling.
