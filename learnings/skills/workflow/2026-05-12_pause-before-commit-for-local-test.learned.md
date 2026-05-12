---
skill: wk-workflow
date: 2026-05-12
type: correction
severity: high
---

Stop before committing when the fix involves an API call, curl command, or external behavior the user may want to verify locally first.

**What happened:** The agent identified a fix for a branch-forwarding API error and immediately invoked `wk-commit` to commit and push. The user interrupted the commit and said "stop I want to test the curl command locally before creating PR fix for that. I can run it locally tell me what you need." The fix was correct, but the user needed to validate the API behavior against their real Buildkite token before the fix was code-frozen in a commit.

**Root cause:** `wk-commit` was invoked immediately after identifying the fix, without checking whether the fix was empirically verified. Fixes that involve API calls, curl commands, or network behavior often can't be fully verified through code inspection alone — they require a live test run.

**Suggested fix:** Before invoking `wk-commit` for a fix that:
- Modifies an API request format (headers, payload structure, endpoint path)
- Changes a curl command used in a shell script
- Alters how an external service is called

Ask: "Do you want to test this locally before I commit?" Give the user the exact command to run and what output confirms the fix works. Commit only after they confirm. This costs one turn but prevents committing an unverified fix.
