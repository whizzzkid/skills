---
skill: wk-docker
date: 2026-10-14
type: surprise
severity: medium
verified-against-source: no
---

Under Compose 5.x, `devcontainer up` failed because the bake builder refused to read the generated features Dockerfile.

**What happened:** The devcontainer CLI's overlay `docker compose build` exited 1, and only a trace log showed
`additional privileges requested: pass "--allow=fs.read=<tmp>/Dockerfile-with-features"`. `COMPOSE_BAKE=false` had no
effect. Setting `BUILDX_BAKE_ENTITLEMENTS_FS=0` let it succeed.

**Root cause:** (unverified — inferred from symptom) Newer Compose always builds through buildx bake. Bake enforces
filesystem entitlements for paths outside the build context, and the devcontainer CLI writes its features Dockerfile
to a temp dir.

**Suggested fix:** When `devcontainer up` fails at "building the Docker Compose images" with a plain base build
succeeding, rerun with `--log-level trace`, grep `privileges`, and retry with `BUILDX_BAKE_ENTITLEMENTS_FS=0`.
Separately: the devcontainer CLI lowercases the compose project name, so `docker compose -p "$(basename "$PWD")_devcontainer" down` fails
on an uppercase worktree directory name; lowercase it.
