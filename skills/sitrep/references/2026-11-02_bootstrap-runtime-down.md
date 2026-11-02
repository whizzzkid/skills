---
class: principle
---

# A failed probe is not a negative result

**Rule** — Step 0 decides "served" by an HTTP answer on `$SITREP_PORT`. A failing `docker` command means the
container runtime is down, never an empty container list: with a compose file present, start the runtime via
`wk-colima`, run `docker compose up -d`, and re-probe over HTTP. "Not installed" is reported only when neither a
compose file nor a local `silverbullet` binary exists.

**Why** — the old probe piped `docker ps 2>/dev/null` into a match, so a daemon-unreachable exit looked identical to
"no container" and fell through to the local-binary branch. A compose-only setup with the runtime stopped was then
reported as "not installed" instead of being started.

**Where** — `SKILL.md` → Step 0; `references/bootstrap.md` → Verify SilverBullet is serving.
