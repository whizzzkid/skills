---
skill: wk-adversarial-review
date: 2026-10-20
type: correction
severity: high
verified-against-source: yes
---

Mutation-test restores must not rely on git inside a container, or on git at all when the tree is dirty.

**What happened:** A mutation run applied the mutant, ran the spec inside a devcontainer, and restored with `git checkout <file>` in the same container. A worktree's `.git` file points at a host path the container cannot see, so git failed and the mutant stayed in the file. On the host, `git checkout` would instead have wiped the uncommitted fix.

**Root cause:** Restoring through VCS assumes a clean tree and a reachable git dir.

**Suggested fix:** Before mutating, copy the file to the playground. Restore from that copy on the host, then grep that the original line is back.
