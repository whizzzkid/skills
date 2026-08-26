---
class: principle
source: learnings/skills/docker/2026-08-25_compose-run-rails-env.md
---

# docker compose run does not inherit service-level environment

`docker compose run` creates a new container from the service definition but
does NOT inherit `environment:` values the same way `docker compose up` does.
One-off `run` invocations use the container's own defaults unless explicitly
overridden with `-e`.

When running specs, always pass `-e RAILS_ENV=test` (or the equivalent for
the framework). Without it, the app defaults to development, which can select
different backends (e.g. RedisJobStore vs MemoryJobStore) and cause universal
spec failures via missing methods.
