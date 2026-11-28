---
class: one-off
source: learnings/skills/docker/2026-11-27_unlinked-brew-docker-cli.learned.md
---

# Unlinked docker CLI surfaced as `spawn docker ENOENT` — already-covered

**Scenario** — A wrapping CLI (devcontainer) failed with `spawn docker ENOENT` while the container VM reported
running; the formula's keg held the binary but its prefix-bin link was missing.

**Symptom** — The error comes from the wrapper's process spawn, not from a shell `command not found`, and the running
VM invites a daemon-side diagnosis.

**Fix** — Already-covered by *Pre-Flight Checks → CLI on PATH (macOS) → Installed but unlinked* (keg-bin PATH prefix
for the one command; tell the user `brew link docker`; never reinstall) and *CLI absent is never a daemon fault*,
shipped in the same-day fold of `2026-11-27_missing-cli-symlink`. This report is the same incident filed twice; the
agent applied the installed fix, so no re-violation and no escalation. Only delta folded: the `spawn docker ENOENT`
symptom string now names the trigger beside `command -v docker` failing.

**Why not promoted** — Distilling it leaves nothing actionable beyond the installed rule.
