---
skill: wk-workflow
date: 2026-08-05
type: correction
severity: low
verified-against-source: yes
---

Announce mixed-toolchain boundaries before invoking a secondary package manager.

**What happened:** A repository used one primary toolchain while an isolated website used another,
and running the website's native test command without first naming that exception looked like a
workflow mistake.

**Root cause:** The workflow correctly read and followed the repository instructions but did not
surface the documented toolchain boundary before emitting the secondary command.

**Suggested fix:** In mixed-toolchain repositories, state which subsystem owns each command before
the first secondary-toolchain invocation and still run the repository-wide primary gate.
