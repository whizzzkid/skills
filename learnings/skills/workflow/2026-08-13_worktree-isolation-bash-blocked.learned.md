---
skill: wk-workflow
date: 2026-08-13
type: gap
severity: high
verified-against-source: yes
---

Worktree-isolated agents cannot run Bash commands

**What happened:** Three parallel agents dispatched with `isolation: "worktree"`
could not execute any Bash command — even `pwd` or `echo probe`. The harness
guard refused every invocation with: "this command runs a string through source,
which can't be verified to stay inside the worktree; run the command directly
instead." One agent discovered that the Monitor tool shares the same shell and
can work around the block, but Grep/Glob were also absent from isolated agents'
tool registries. Agents could still use Read/Edit/Write, so code edits succeeded
but tests, linting, commits, and PR creation all failed.

**Root cause:** The worktree-isolation sandbox validates that Bash commands stay
inside the worktree path, but its string-through-source detection is
over-aggressive and blocks all shell invocations. This is a harness-level
constraint, not a skill bug.

**Suggested fix:** When dispatching parallel agents for independent file edits:
(a) do not use `isolation: "worktree"` if agents need Bash (tests, lint, commit,
push), or (b) plan for the coordinator session to handle all Bash operations on
the worktree paths after agents complete their Read/Edit/Write work. Document
this split-responsibility pattern in the workflow skill's parallelism section.
