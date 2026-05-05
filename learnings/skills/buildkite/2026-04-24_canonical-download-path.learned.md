---
skill: wk-buildkite
date: 2026-04-24
type: gap
severity: medium
---

Buildkite artifact / log / build-json downloads should land in a canonical, structured path — not random `/tmp/foo.log` names.

**What happened:** While debugging CI failures, I dumped Buildkite artifacts
to ad-hoc paths: `/tmp/bk9285.json`, `/tmp/rubocop.log`, etc. These paths
have no structure, collide across builds, leak across sessions, and get
overwritten silently when investigating multiple failures (e.g. the same
`/tmp/rubocop.log` for build 9285 and 9301). When two agents or two
sessions touch the same machine, the lack of namespacing turns into a
correctness problem (one agent's log overwrites another's), and there's
no audit trail — once `/tmp/foo.log` is overwritten, the original is
gone.

**Root cause:** The wk-buildkite skill describes how to fetch logs and
artifacts (`bk job log`, `bk artifact download`, raw curl on the API)
but says nothing about *where* to put them. The natural default is
`/tmp/<friendly-name>` which has none of the structure needed for
multi-build / multi-session work.

**Suggested fix:** Add a "Canonical download path" subsection to
wk-buildkite:

> All Buildkite downloads (build JSON, job logs, artifacts) must land
> under a canonical path:
>
> ```
> /tmp/agent/buildkite/<build_number>/<job_id>/<filename>
> ```
>
> Examples:
>
> - Build JSON: `/tmp/agent/buildkite/9285/build.json`
> - Job log:    `/tmp/agent/buildkite/9285/019dc16b-6003-4a01-90e7-d730dbd46a6a/log.txt`
> - Artifact:   `/tmp/agent/buildkite/9285/019dc16b-.../artifacts/findings.json`
>
> Create the directory with `mkdir -p` before writing. This namespace
> survives parallel investigations, prevents cross-session
> overwrites, and gives an obvious audit trail
> (`ls /tmp/agent/buildkite/` lists every build the agent has touched).

The same canonical-path convention should apply across all skills that
download from external systems (gh, datadog, etc.) — see the matching
learning under `gh/`.
