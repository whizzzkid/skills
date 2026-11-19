---
class: principle
---

# Replay a foreign snippet under its own interpreter

**Rule** — When verifying a claim about a CI step or another tool's script, run the snippet verbatim under its
declared interpreter (`bash -c '…'` or a `.sh` run with `bash`), never in the agent's login shell. Swap
platform-specific tools for the CI host's equivalent (`stat -c` on Linux vs `stat -f` on BSD/macOS).

**Why** — The portability rule governs commands the agent authors; a replay must not rewrite the code under test, so
portability cannot save it. Reproduced under zsh 5.9: `L="a b c"; for e in $L` iterates once under zsh, three times
under bash. The zsh replay reported a failure the CI run would never hit, and the failure read as a defect in the
script being verified.

**Rejected** — the source's advice to keep scratch files in a fixed temp dir so cleanup avoids a variable-based
`rm -rf`: that is a harness permission-check workaround, not a shell principle.

**Where** — `wk-workstyle-shell` → Rules → zsh/bash portability sub-bullet.
