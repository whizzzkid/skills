---
skill: wk-devcontainer
date: 2026-11-24
type: surprise
severity: medium
verified-against-source: yes
---

Container-level env overrides meant for development also apply to test runs; guard the suite. Do not change branches
while post-create is installing dependencies.

**What happened:** (1) An opt-in env override forwarded into the dev container (config-source env vars) also turned a
feature on under the test environment, so specs could reach the network; a negative control (guard removed) failed 4
specs. A pre-existing env override already caused one unrelated spec failure the same way. (2) Switching git branches
while the container's post-create `bundle install` was running produced a GemNotFound on the next step, because the
lockfile changed mid-install.

**Root cause:** Compose `environment:` applies to every process in the container regardless of the app environment;
post-create reads the working tree live.

**Suggested fix:** For any opt-in dev override, add a test-suite guard (unset the vars in a spec support file before
any read) and document it. Settle the branch before `devcontainer up`, or re-run post-create after switching.
