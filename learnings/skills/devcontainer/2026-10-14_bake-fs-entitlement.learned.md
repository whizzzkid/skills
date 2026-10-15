---
skill: wk-devcontainer
date: 2026-10-14
type: gap
severity: medium
verified-against-source: no
---

`devcontainer up` can fail because compose bake requests a filesystem entitlement for the generated features Dockerfile.

**What happened:** `devcontainer up` failed with a generic "error occurred building the Docker Compose images". Running
the generated compose overlay by hand surfaced the real message:
`additional privileges requested: pass "--allow=fs.read=<tmp>/Dockerfile-with-features"`. Neither `COMPOSE_BAKE=false`
nor `BUILDX_BAKE_ENTITLEMENTS_FS=0` passed through the CLI fixed it. The config declared no features, so the overlay
added nothing. Bringing the stack up with plain `docker compose -p <project> -f .devcontainer/docker-compose.yml`
worked. Because a sibling worktree's stack already held the app's published port, the app had to run via
`compose run --rm` (which publishes no ports) instead of `up`.

**Root cause:** (unverified — inferred from symptom) Newer compose/buildx gate bake builds that read files outside the
build context, and the devcontainer CLI places its generated Dockerfile in a temp directory.

**Suggested fix:** When `devcontainer up` fails at the build step, rerun the generated overlay command by hand to get the
real error. If the config has no features, fall back to plain compose plus `post-create.sh`. Use `compose run --rm` when
another worktree's stack already holds the published ports.
