---
skill: wk-workflow
date: 2026-08-17
type: surprise
severity: medium
verified-against-source: yes
---

Devcontainer compose injects RAILS_ENV=development, breaking rspec

**What happened:** Three independent parallel agents all discovered that running
`bin/rspec` inside the devcontainer fails because `docker-compose.yml` sets
`RAILS_ENV=development`, and `spec/rails_helper.rb` uses `||=` so it never
overrides to `test`. Every spec errors on missing dev-mode infrastructure
(e.g. `RedisJobStore#clear` undefined). All agents independently worked around it
with `-e RAILS_ENV=test`.

**Root cause:** The compose service's environment block sets `RAILS_ENV=development`
unconditionally; `rails_helper.rb`'s `ENV['RAILS_ENV'] ||= 'test'` defers to the
already-set value. This is a pre-existing env issue, not caused by any of the
changes.

**Suggested fix:** When briefing agents that will run specs in a devcontainer, include
the workaround (`RAILS_ENV=test`) in the prompt. Separately, fix the root cause:
either remove `RAILS_ENV` from the compose service or change `rails_helper.rb` to
`ENV['RAILS_ENV'] = 'test'`.
