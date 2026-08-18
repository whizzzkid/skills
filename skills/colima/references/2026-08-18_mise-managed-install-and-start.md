---
class: principle
---

# Colima is mise-managed: install and invoke through mise

**Rule** — Colima is a mise tool, not a brew package. Install via
`mise use -g colima@latest` (Lima is a colima dependency installed alongside it,
not a separate package), and run every `colima`/`docker` command through
`mise exec --`. A bare `colima status` on a mise-managed install fails with
`dependency check failed for VM: lima not found` — the binary exists but its
Lima backend is not on the bare-shell PATH. Bare `docker` calls then report
`failed to connect to the docker API` even when the daemon is healthy, because
the socket is not where the bare CLI looks.

**Why** — Two independent mismatches: (1) the install instruction named a
package manager the project does not use; (2) invocations outside `mise exec --`
leave mise-pinned tools and their dependencies off PATH, and Docker
context/socket resolution falls back to defaults that do not match the mise
install. A mise-managed colima serves its socket under `$HOME/.config/colima/`, not
   the `$HOME/.colima/` path the bare CLI assumes — resolve the socket from
`docker context ls`, never assume a path.

**Memory** — Derive memory from the host, never hardcode it. The VZ driver
rejects requests above the host's `maximumAllowedMemorySize`, so read the
machine's memory (`sysctl -n hw.memsize` on macOS), halve it, floor at 1 GB, and
never exceed what the host allows. Same for CPU — derive the count dynamically
rather than pinning it.

**Where** — `wk-colima` Steps 1–4 (all `colima`/`docker` invocations), Step 2
(CPU/memory derivation), Requirements.