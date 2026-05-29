---
skill: wk-pr
date: 2026-05-22
type: correction
severity: high
---

Self-review posted via raw `gh api .../comments` — interrupted by user before posting.

**What happened:** Agent was about to post self-review inline comments using raw `gh api repos/.../pulls/{n}/comments` which publishes immediately, bypassing the pending-review human-in-the-loop checkpoint. User denied the tool call.

**Root cause:** The self-review skill was not invoked via `Skill(wk-self-review)` — agent composed the API call directly. The HARD RULE in wk-self-review requires pending review via `/pulls/{n}/reviews`, not direct comment posting.

**Suggested fix:** wk-pr must never compose inline comment payloads directly; always delegate to `wk-self-review` which enforces the pending-review flow.
