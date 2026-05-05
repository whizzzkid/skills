---
skill: wk-pr-review
date: 2026-04-30
type: pattern
severity: high
---

When reviewing session/resume flows that use Buildkite artifact download, always verify path-preservation.

**What happened:** PR switched session JSONL upload to `claude-sessions/*.jsonl` but the Rust entrypoint's `prepare_session_resume` used non-recursive `read_dir` to scan `.{job}-resume/`. Buildkite preserves the `claude-sessions/` subdir on download, so the file landed at `.{job}-resume/claude-sessions/{id}.jsonl` and was never found — then `remove_dir_all` wiped it. Tests passed because the harness placed files at `.{job}-resume/{id}.jsonl` directly (wrong layout in both directions).

**Root cause:** Migration from bash (`find -name '*.jsonl'`, recursive) to Rust (`read_dir`, non-recursive) dropped the recursion silently. The test harness was updated to match the *new* entrypoint read path, not the *actual* download path, so both were wrong in the same direction.

**Suggested fix:** When reviewing artifact-download→consume flows: (1) verify the download command's destination pattern matches how the consumer scans for files, (2) check whether the consumer recurses or is flat, (3) verify test harness mirrors production artifact layout not just the entrypoint's scan assumption.
