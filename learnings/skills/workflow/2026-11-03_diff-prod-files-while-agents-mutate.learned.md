---
skill: wk-workflow
date: 2026-11-03
type: pattern
severity: high
verified-against-source: yes
---

Never commit while mutation-testing agents may still hold a production file mutated; diff production files first.

**What happened:** A request to open the PR arrived while spec agents were mutation-testing. A production file on disk held a deliberately broken line; a diff check before committing caught it, and the commit waited for the agents to restore it.

**Root cause:** Parallel agents share the working tree, and their temporary mutations are indistinguishable from real edits to a commit.

**Suggested fix:** Before every commit while agents run: confirm the workflow finished, then `git diff` every production file against the intended change. Tell mutation agents to work on copies, or not to mutate lib files other agents load.
