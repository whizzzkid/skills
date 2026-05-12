---
skill: wk-buildkite
date: 2026-05-12
type: correction
severity: medium
---

Use the project-installed `bk` CLI instead of `npx bktide@latest` or other ad-hoc tools for Buildkite operations.

**What happened:** When needing to inspect a Buildkite build, the agent ran `npx bktide@latest builds ...`. The user interrupted and provided the Buildkite URL directly, then later said "just use `bk` cli instead" when the agent tried WebFetch on the URL. Multiple turns were wasted fetching via the wrong tool.

**Root cause:** The agent defaulted to an npx-fetched tool (`bktide`) instead of the project's installed CLI (`bk`). This added npm download overhead, bypassed auth, and ignored the user's preferred tool stack.

**Suggested fix:** In any `wk-buildkite` flow needing to inspect builds or annotations:
1. Check if `bk` is available on PATH: `which bk`
2. If yes, use `bk build view`, `bk build annotate`, etc.
3. Only fall back to the REST API via `curl` if `bk` is unavailable AND the user approves.
4. Never use `npx bktide` or `WebFetch` on a Buildkite URL when `bk` is available.
5. If the user pastes a Buildkite URL, use `bk build view --url <url>` or parse the build number from the URL and use `bk build view -b <number>`.
