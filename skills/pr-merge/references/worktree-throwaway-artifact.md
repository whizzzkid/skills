---
class: principle
---

**Rule** — When `git wtr` fails on untracked/modified files, run `git status --short`;
if every entry is a recognizable throwaway artifact (test-runner state like rspec
last-failures, `tmp/`, coverage output), delete just those and retry the clean `git wtr`
once. Reserve `--force` (and any confirmation ask) for genuine uncommitted work.

**Why** — With no throwaway-artifact handling, the agent defaulted to `--force` +
`git branch -D` (tripping the destruction classifier) and asked the user to confirm the
force removal twice — three turns of hand-holding for a stale rspec-failures file.

**Where** — `skills/pr-merge/SKILL.md` Step 10 worktree cleanup.
