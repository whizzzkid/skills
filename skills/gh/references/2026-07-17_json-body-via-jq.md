---
class: principle
---

**Rule** — Build any non-trivial `gh api` POST/PATCH JSON body with `jq -n --arg`,
never a heredoc with hand-escaped quotes/backticks.

**Why** — Manual string interpolation into a JSON literal corrupts the structure on
any special char in the content, and the failure surfaces only as an opaque
`HTTP 400 "Problems parsing JSON"` from the API — no local syntax error catches it
first. `jq` escapes all content correctly regardless of what it contains.

**Where** — Step 3, GitHub write payloads (e.g. review-comment bodies):
`jq -n --arg body "$text" '{body: $body, event: "COMMENT"}' | gh api ... --input -`.
