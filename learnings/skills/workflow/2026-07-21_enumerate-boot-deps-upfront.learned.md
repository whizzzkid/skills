---
skill: wk-workflow
date: 2026-07-21
type: correction
severity: medium
---

When reproducing a full app boot locally, enumerate every config/secret dependency upfront instead of discovering them one boot-failure at a time.

**What happened:** Reproducing a production `assets:precompile` boot required many injected config values (secret_key_base, DB credentials, redis.*, kafka.*, api tokens). The agent discovered each missing key iteratively — boot, read the error naming the next missing key, add it, re-boot. The user interrupted to ask for a clean, repeatable local test setup rather than watching the trial-and-error loop.

**Root cause:** The agent treated each boot failure as the signal for the next fix, rather than reading the config resolver / schema and the repo's existing env-override convention to list all required keys before the first attempt.

**Suggested fix:** Before reproducing a boot that resolves config through a secrets layer, grep the config manifest and any existing dev-container/compose env-override file to enumerate the full required-key set in one pass; inject them together, then boot once. Trial-and-error boot loops are a signal to stop and read the schema.
