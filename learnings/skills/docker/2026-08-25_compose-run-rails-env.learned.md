---
skill: wk-docker
date: 2026-08-25
type: gap
severity: medium
verified-against-source: yes
---

`docker compose run` without explicit `RAILS_ENV=test` defaults to development, breaking entire spec suite

**What happened:** Running specs via `docker compose run --rm -T app bash -lc 'bundle exec rspec ...'` failed universally because `RAILS_ENV` defaulted to `development`. The app's database-pull initializer selects `RedisJobStore` in non-test environments, whose `#clear` method doesn't exist — the global `before` hook in spec support calls `.clear` on the job store, so every single example failed identically with `NoMethodError`.

**Root cause:** The devcontainer's `docker-compose.yml` sets `RAILS_ENV` for the `app` service when started via `docker compose up`, but one-off `docker compose run` invocations inherit the container's own default (development) unless explicitly overridden with `-e RAILS_ENV=test`. The initializer's `Rails.env.test?` guard then takes the non-test branch and configures `RedisJobStore` instead of `MemoryJobStore`.

**Suggested fix:** When the skill or agent runs specs via `docker compose run` (rather than `exec` on a running `up`-managed container), always pass `-e RAILS_ENV=test`. Document this in the devcontainer guidance — `run` and `exec` have different env inheritance semantics.
