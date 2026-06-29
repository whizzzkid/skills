---
skill: wk-sharpen
date: 2026-06-29
type: pattern
severity: low
---

A batch run can be a recovery: a fully-distilled fold staged but uncommitted by a signer-blocked prior session is a valid terminal state to resume, not new work.

**What happened:** `/wk-sharpen` (batch, no args) opened with all learnings/retros already renamed `.learned.md`, all skill edits staged (`git status` showed A/M), and the prior session's note "blocked on signer unlock". Inbox empty; memory backlog 0 once normalized. The only outstanding action was re-running the terminal gate (install + prohibited scan) and retrying the commit — which succeeded because the signer had since unlocked.

**Root cause:** Step 8 says to stop and ask the user on signer failure, but does not state that on the *next* run the staged fold is resumable. Without that, an agent could mistake "everything is `.learned.md`" for "nothing to do" and skip the pending commit, or re-distill already-folded work.

**Suggested fix:** In batch mode, before concluding "sources drained / nothing to do", check for a staged-but-uncommitted fold (`git diff --cached --name-only` non-empty with SKILL.md/README/references). If present, treat it as resumable: re-run install + prohibited scan, then retry the commit. Also reinforce the existing `comm` format-mismatch guard — an all-undistilled memory diff is a path-form trap (full-path marker vs basename listing), confirmed by re-normalizing both sides to full paths (0 real backlog).
