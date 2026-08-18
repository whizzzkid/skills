---
skill: wk-colima
date: 2026-08-18
type: correction
severity: high
verified-against-source: yes
---

Colima is mise-managed: install via `mise use -g colima@latest`, and always invoke colima/docker through `mise exec --`.

**What happened:** The skill's Requirements section says `brew install colima`, and every command in the skill body runs `colima` / `docker` bare. On a machine where colima is installed through mise, a bare `colima status` fails with `dependency check failed for VM: lima not found` - the binary exists but its Lima backend dependency is not on the bare-shell PATH. The same bare `docker` calls then report `failed to connect to the docker API` even though the daemon is healthy, because the socket path is not where the bare CLI looks.

**Root cause:** Two independent mismatches between the skill's instructions and this environment. (1) The install instruction names a package manager the project does not use; the project's own toolchain rule is mise, and colima is a mise tool here. (2) Every colima/docker invocation in the skill runs outside `mise exec --`, so mise-pinned tools and their dependencies are not on PATH, and the Docker context/socket resolution falls back to defaults that do not match the mise install. The socket a mise-managed colima serves is under `$HOME/.config/colima/`, not the `$HOME/.colima/` path the bare CLI assumes.

**Suggested fix:** Replace the `brew install colima` requirement with `mise use -g colima@latest` (Lima is a colima dependency installed alongside it, not a separate brew package). Prefix every colima and docker command in Steps 1-5 with `mise exec --`, including `docker info` reachability checks. Detect the Docker socket from `docker context ls` rather than assuming a path. For the memory profile, query the host's available memory instead of hardcoding a value: the VZ driver rejects requests above the host's `maximumAllowedMemorySize`, so read the machine's memory (e.g. `sysctl -n hw.memsize` on macOS, halved and floored at 1 GB) and never exceed what the host allows. Same for CPU - derive the count dynamically rather than pinning it.
