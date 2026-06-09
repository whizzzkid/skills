---
skill: wk-adversarial-review
date: 2026-06-09
type: gap
severity: medium
---

When a build flag is added for correctness, sweep every sibling invocation of the same toolchain in the repo — and beware environment-masked reproductions.

**What happened:** `-buildvcs=false` was added to the wasm/binary build scripts after reproducing VCS-stamping nondeterminism, but the parity script's own `go build`/`go run` calls were missed; CI failed with "error obtaining VCS status". The local reproduction also masked the issue because linked git worktrees suppress Go's VCS stamping, so local runs passed.

**Root cause:** Same-semantic-class audit was applied to build scripts but not to all `go build|go run|go test` call sites; the local environment (worktree) differed from CI (clone) in a way that hid the failure.

**Suggested fix:** Add to the sweeps: when a flag/env fix is applied to one toolchain invocation, grep the whole repo for sibling invocations of that toolchain and apply or justify each; and treat "works locally in a linked worktree" as weak evidence for VCS-dependent behavior — prefer `export GOFLAGS` at script top over per-call flags.
