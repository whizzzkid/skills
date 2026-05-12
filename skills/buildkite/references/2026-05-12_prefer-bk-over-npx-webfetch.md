---
name: prefer-bk-over-npx-webfetch
description: Use installed bk CLI; never substitute npx tools or WebFetch on Buildkite URLs.
---

- **Rule:** Resolve `bk` on PATH at the start of any Buildkite flow; parse
  pipeline/build from pasted URLs and use `bk build view`. Do not `npx`
  alternative Buildkite CLIs or `WebFetch` the URL.
- **Why:** `npx`-fetched tools bypass project auth, the HTML view lacks
  structured job data, and substituting tools ignores the user's stack.
- **Where:** "Tool Selection" HARD RULE in `buildkite/SKILL.md`.
