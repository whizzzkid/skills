---
class: principle
---

# Fail fast between dependent verification gates

- **Rule:** Run expected-red proofs and later green gates in separate tool
  calls, or start their shared shell command with `set -euo pipefail`.
- **Why:** Newline-delimited shell commands otherwise continue after a failed
  proof, causing misleading cascades and orphaned processes.
- **Where:** [`wk-workflow`](../README.md) Phase 3 verification.
- **Budget:** Body `23047 + 262 = 23309` bytes, leaving 1,267 bytes.
