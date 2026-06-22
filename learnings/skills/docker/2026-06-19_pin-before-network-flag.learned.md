---
skill: wk-docker
date: 2026-06-19
type: correction
severity: high
---

When diagnosing dind Docker build failures, check for floating image tags before adding --network=host.

**What happened:** A dind CI test step failed because `cargo build` inside a multi-stage Docker build could not reach the crates.io sparse registry. The agent's first fix was to add `--network=host` to the `docker build` command. The user redirected: "can we fix this without adding `--network=host`?"

**Root cause:** The actual cause was a floating base image tag (`rust:bookworm`) pulling new upstream layers, invalidating the Docker layer cache, and forcing a fresh `cargo build --release` that needed external network access the dind bridge network lacks. The fix was to pin the tag (`rust:1.93-bookworm`) so the layer cache is stable and `cargo build` never runs cold inside dind. Adding `--network=host` to the build command would have been a workaround masking the real issue rather than fixing it.

**Suggested fix:** Add a pre-flight step to the Docker debugging flow: when a `RUN` step inside a `docker build` fails with a network/fetch error inside dind, first check whether the stage's `FROM` image uses a floating tag. A floating tag that recently updated invalidates the layer cache and causes that `RUN` to execute cold. Pin the tag to match the project's tool-version file (e.g. `mise.toml`, `.tool-versions`) before reaching for `--network=host`. Reserve `--network=host` for cases where pinning is not possible or the failure is not cache-related.
