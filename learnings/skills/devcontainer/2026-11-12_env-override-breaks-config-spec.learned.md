---
skill: wk-devcontainer
date: 2026-11-12
type: surprise
severity: low
verified-against-source: yes
---

A devcontainer that exports config-override env vars breaks specs that read the real config file.

**What happened:** One untouched spec failed in the full suite. It asserts that a token from the YAML `test` block authenticates, but the container exported the config library's env override for that key, so the YAML value was replaced.

**Root cause:** The config library gives env vars of the form `CONFIG__<SECTION>__<KEY>` precedence over the YAML file. Confirmed: with that variable unset, all 17 examples in the spec pass.

**Suggested fix:** When a spec that reads real config fails only inside the container, list `env | grep ^CONFIG__` (names only, never values) and re-run with `env -u <VAR>`. Record the override in the PR test plan instead of treating it as a regression.
