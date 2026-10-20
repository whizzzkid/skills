---
skill: wk-docker
date: 2026-10-20
type: surprise
severity: medium
verified-against-source: no
---

Compose builds via Bake fail with "additional privileges requested: --allow=fs.read=..." for devcontainer feature Dockerfiles outside the context.

**What happened:** `devcontainer up` failed; `COMPOSE_BAKE=false` did not avoid it; `BUILDX_BAKE_ENTITLEMENTS_FS=0` did. Separately, a shutdown command using `$(basename "$PWD")_devcontainer` as the compose project name failed for a worktree dir with uppercase letters — compose lowercases project names.

**Root cause:** (unverified — inferred from symptom) newer buildx enforces fs entitlements for Bake reads outside the build context; devcontainer CLI writes its generated Dockerfile to a temp dir.

**Suggested fix:** On that error, retry with `BUILDX_BAKE_ENTITLEMENTS_FS=0`. Lowercase derived compose project names (`tr '[:upper:]' '[:lower:]'`).
