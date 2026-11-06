---
skill: wk-renovate
date: 2026-11-06
type: surprise
severity: medium
verified-against-source: yes
---

Lockfile regen in a devcontainer can fail on private-registry auth, and a red spec can come from forwarded host env.

**What happened:** `devcontainer exec bundle update` failed with "Authentication is required" for the private gem
source, although container creation had run `bundle install` fine. Later, one spec failed deterministically after
the bumps; it passed once a host-forwarded config-override env var was unset.

**Root cause:** The container's post-create script exported the registry credential var only within its own shell, so
later `exec` sessions lacked it. Separately, the compose file forwards host config-override env vars
(`CONFIG__*`-style) into the container, overriding the test-env config value the spec reads.

**Suggested fix:** In Step 3/4, when regenerating a lockfile inside a container, mirror the post-create script's
credential export inline in the exec command. Before attributing a deterministic single-spec failure to a bump, dump
`env` for config-override vars and re-run with them unset (in addition to rerunning on base).
