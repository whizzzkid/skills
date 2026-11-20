---
skill: wk-workflow
date: 2026-11-20
type: correction
severity: low
verified-against-source: yes
---

Code comments that describe a third-party tool's behavior must be checked against that tool's source before commit.

**What happened:** New CI-wiring comments claimed a validate command uniquely caught a failure class that the loader
already rejected at pipeline upload, called a passthrough "untouched" when the library rejected one key and
shallow-merged defaults, and called a step "cheap" while its container plugin still started and health-waited on
unused services (default `dependencies: true`). The adversarial review caught all three; a fresh-context refuter
reproduced each one.

**Root cause:** The comments came from the library's docs and a reading of intent, not from its parser, its CLI
dispatch, or the plugin's defaults.

**Suggested fix:** In Phase 2, for every comment that states what an external tool does or doesn't check, grep the
tool's source for the mechanism, or drive it once against a scratch copy. Also check plugin defaults (dependencies,
env propagation) whenever you claim a step is cheap or isolated.
