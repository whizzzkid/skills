---
skill: wk-devcontainer
date: 2026-10-21
type: surprise
severity: medium
verified-against-source: no
---

`devcontainer up` with a features Dockerfile fails under compose bake's fs entitlement check.

**What happened:** Build of the features layer exited 1 with "additional privileges requested: pass
--allow=fs.read=<tmp>/Dockerfile-with-features". Setting COMPOSE_BAKE=false did not help; prefixing
`BUILDX_BAKE_ENTITLEMENTS_FS=0 devcontainer up --workspace-folder .` succeeded.

**Root cause:** (unverified — inferred from symptom) Newer buildx bake enforces filesystem entitlements for files
outside the build context, and the devcontainer CLI writes its generated Dockerfile to a temp dir.

**Suggested fix:** In wk-devcontainer troubleshooting, map this error to `BUILDX_BAKE_ENTITLEMENTS_FS=0`.
