---
skill: wk-workflow
date: 2026-11-21
type: practice
severity: low
verified-against-source: n/a
source: learnings/retrospect/2026-11-21_session-1 (What worked)
---

A single source-of-truth version pin, read by one shared install script that asserts the result, removed drift.

**What happened:** One pin file was read by a shared install script used by both images and hosts, with an assert
that the installed version matches the pin. Drift between images and hosts disappeared, with no second copy to
maintain.

**Suggested fix:** Keep one pin file per tool, read by every installer, and assert the installed version after install.
