---
skill: wk-buildkite
date: 2026-06-08
type: gap
severity: medium
---

`bk build view -b` takes a branch name, not a build number — piping the result directly to `jq` fails when the build is not found.

**What happened:** Used `bk build view -p {pipeline} -b {build-number} --json | jq ...` expecting to fetch a specific build by number. The `-b` flag is for branch name, so the lookup returned `null\n`, causing `jq` to error with "Invalid numeric literal".

**Root cause:** The skill's canonical build query shows `-b <branch>` and a comment says "swap for build number" but the flag semantics are different — `-b` always takes a branch name in `bk build view`.

**Suggested fix:** Document that to fetch a specific build by number, use `bk build view -p <pipeline> --json` to get the latest, or fetch and save to file first before piping to `jq` to avoid null-output parse errors. Clarify in the canonical query comment that `<build-number>` in the comment refers to the branch's latest build, not a numeric build ID.
