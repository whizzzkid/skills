---
class: principle
source: learnings/skills/sitrep/2026-11-10_docker-cli-unlinked.learned.md
date: 2026-11-10
skill: wk-sitrep
---

# Probe the CLI before the daemon

**Rule** — In Step 0, run `command -v docker` before `docker info`. CLI absent → report a CLI install/link gap and fix
it per `wk-docker` Pre-Flight; never start or restart the container runtime. Only a present CLI with a failing
`docker info` means the runtime is down. Gathering agents retry a `command not found` or an unset env var once with
`$HOME/.profile` sourced before reporting the domain unavailable.

**Why** — "CLI absent" and "daemon unreachable" both exit non-zero, so a daemon-only probe misreads an unlinked
package as a stopped runtime. The runtime start then fails too, because Colima's dependency check refuses to start
without the `docker` binary, and a restart loop cannot fix a missing file. Agent shells may not source the user's
profile, so a toolless or env-less agent is not yet proof of a missing connector.

**Already covered (no escalation)** — a truncated agent report fixed by one section-scoped resend is the existing
`subagent-contract.md` → "Orchestrator: truncated results" rule firing correctly.

**Where** — `SKILL.md` → Step 0 (probe sub-bullet) and start Stage 2 block handling; `references/bootstrap.md` →
Verify SilverBullet is serving (`cli-absent` state); `references/subagent-contract.md` (profile retry line);
`wk-docker` Pre-Flight; `wk-colima` Step 1.
