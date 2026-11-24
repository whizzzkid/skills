---
class: principle
---

# Permission-layer denials during posting

Relocated from `SKILL.md` to hold the body under its size ceiling. The never-retry rule for each denial stays inline;
this file carries the preflight and recovery mechanics.

## Approve submit denied

- A permission layer may deny the approve submit (e.g. classed as self-approval); the `approve` token does not bind
  the permission layer.
- Never retry, resubmit as `COMMENT`, or open a second review: the pending review already holds every comment.
- Report its `html_url`, the approve payload path, and the exact `events` POST. The user submits Approve on GitHub or
  adds a Bash allow rule. Never self-edit settings.
- **Preflight:** auto mode with no `gh api` reviews allow rule in the settings files → say so in the Phase 4 summary
  first (mirrors `wk-pr-merge`'s permission preflight).
- Hook-rewrite denial (`a hook changed this call's input`) → the one-retry POST rule in Phase 5, not this path.

## `open` denied

- In auto mode a classifier can treat launching a browser as an outward-facing action and deny the Phase 5 `open`.
- The review is already posted, so only the browser tab is lost: print the `html_url` in the terminal summary and
  move on. Never retry the `open` or work around the denial (another launcher, a URL handler, a settings edit).
