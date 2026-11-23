---
skill: wk-buildkite
date: 2026-11-20
type: correction
severity: medium
verified-against-source: no
---

Pass the full 40-character SHA to `bk build list --commit`; with a short SHA, the watch loop never finds the build.

**What happened:** A background watch called `bk build list --commit <7-char sha>`. Every poll reported "none queued", even though the build for that commit ran and passed. The watch ran until the background time limit killed it.

**Root cause:** (unverified — inferred from symptom) The commit filter matches the exact full SHA and does not do prefix matching. The loop treated "no build found" as "still queued" and kept polling.

**Suggested fix:** In the watch-loop template, resolve the full SHA first (`git rev-parse <ref>` or `git ls-remote`), as the template already does. Never accept a short SHA. Also add a poll cap that exits non-zero when `none` persists for N polls, so a filter that matches nothing fails loudly instead of running until the time limit.
