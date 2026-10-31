---
class: principle
skill: wk-workstyle-testing
date: 2026-10-31
severity: medium
---

**Rule** — When code classifies a dependency's error by its message text, keep at least one test that provokes the
real error from the real dependency, beside the stubbed cases. For a database driver, that means a real-database
canary that triggers the actual failure.

**Why** — A session retrospect reported that a real-database canary caught driver message drift that every
string-stubbed test missed. A stubbed error encodes the wording observed once, so it stays green after the dependency
rewords the message, while production silently stops matching. `wk-testing-skeleton` already requires capturing the
exact wording before writing the matcher, but that is a one-time probe and does nothing once the dependency changes.
A persistent real-error test turns drift into a red test.

**Where** — `SKILL.md` → Rules, "Error-text matchers need one real-error test".
