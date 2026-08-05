---
skill: wk-workflow
date: 2026-08-04
type: correction
severity: medium
verified-against-source: yes
---

Make the user-loadable development build the final artifact-producing handoff step.

**What happened:** A valid local development package was rebuilt before a required CI hook, but
the hook's build tests could replace the output directory with a different artifact shape before
the user loaded it.

**Root cause:** Verification and artifact handoff were treated as independent completed steps even
though the verification pipeline itself writes to the same output directory.

**Suggested fix:** Identify every gate that writes the handoff directory, run those gates first,
then execute and validate the development build as the final local artifact-producing command.
