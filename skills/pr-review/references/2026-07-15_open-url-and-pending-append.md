---
class: principle
---

**Rule** — (1) Firing `open` on the review `html_url` is a non-optional final
action on every review create AND recreate, independent of whether the POST
response parsed; re-query to recover the URL if parsing fails. (2) Adding comments
to an existing pending review requires `DELETE /pulls/{n}/reviews/{id}` then
re-POSTing the review with the full comment set — GitHub rejects appends with 422
"one pending review per pull request".

**Why** — (1) The open step was dropped when the create response jq-parse errored
and attention shifted to verifying the review landed; the recreate flow omitted it
too. (2) Pending-review comments return `line: null` and cannot be round-tripped,
so the full set must be rebuilt on recreate.

**Where** — wk-pr-review Phase 5: "After posting" HARD RULE + "Add comments to an
existing pending review" subsection.
