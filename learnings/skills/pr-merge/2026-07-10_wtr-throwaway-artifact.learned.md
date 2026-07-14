---
skill: wk-pr-merge
date: 2026-07-10
type: correction
severity: medium
---

When `git wtr` fails only because of a recognizable throwaway artifact, delete the artifact and retry the clean alias — do not escalate to `--force` or ask.

**What happened:** Worktree cleanup (Step 10) ran `git wtr <name>`, which failed with "contains modified or untracked files, use --force". The only dirty entry was a throwaway test artifact (an rspec last-failures file). The agent escalated to a `--force` + `git branch -D` command (tripping the destruction classifier), then asked the user to confirm the force removal — twice — instead of just removing the artifact and retrying. The user had to hand-hold through three turns.

**Root cause:** Step 10 gives the clean `git wtr` path but no handling for the common "dirty only due to a generated/throwaway artifact" case, so the agent defaulted to `--force` (maximally destructive) and confirmation prompts.

**Suggested fix:** In Step 10, when `git wtr` fails on untracked/modified files, run `git status --short`; if every entry is a recognizable throwaway artifact (test-runner state like `.rspec_failures`, `tmp/`, coverage output), delete those specific files and retry the clean `git wtr` once — reserve `--force` (and any confirmation ask) for genuine uncommitted work the user might want.
