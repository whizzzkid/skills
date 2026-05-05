---
skill: wk-gh
date: 2026-04-24
type: gap
severity: medium
---

GitHub artifact / log / API-response downloads should land in a canonical, structured path — not random `/tmp/foo` names.

**What happened:** While debugging the PR (review JSON for the
self-review payload, PR body drafts, GraphQL responses), I dumped
content to ad-hoc paths like `/tmp/self_review.json`. The same problem
as the buildkite case: no namespacing, collisions across PRs, no audit
trail, ambient state that leaks across sessions.

**Root cause:** The wk-gh skill describes how to interact with the
`gh` CLI (issues, PRs, checks, releases) but doesn't specify where
intermediate or downloaded files should live. The natural default is
`/tmp/<friendly-name>` which has no structure for multi-PR work.

**Suggested fix:** Add a "Canonical download path" subsection to
wk-gh:

> All `gh` downloads, API response bodies you save to disk, and
> intermediate review/PR payloads must land under a canonical path:
>
> ```
> /tmp/agent/gh/<owner>/<repo>/<resource_type>/<resource_id>/<filename>
> ```
>
> Examples:
>
> - PR body draft:   `/tmp/agent/gh/$GITHUB_ORG/{repo}/pulls/{n}/body.md`
> - Self-review JSON: `/tmp/agent/gh/$GITHUB_ORG/{repo}/pulls/{n}/self_review.json`
> - Issue comments:   `/tmp/agent/gh/$GITHUB_ORG/{repo}/issues/{n}/comments.json`
> - Workflow run log: `/tmp/agent/gh/$GITHUB_ORG/{repo}/runs/{n}/log.txt`
>
> Create the directory with `mkdir -p` before writing. This survives
> parallel work on multiple PRs, makes it obvious which payload
> belongs to which resource, and gives a trivially-greppable audit
> trail (`ls /tmp/agent/gh/$GITHUB_ORG/{repo}/pulls/`).

The same convention applies across skills that download from external
systems — see the matching learning under `buildkite/`.
