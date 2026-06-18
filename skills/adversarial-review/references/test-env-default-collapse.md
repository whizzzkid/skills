---
class: principle
---

**Rule:** Flag an env-var-fallback test that collapses to the explicit-default assertion because the test harness's base env already supplies the tested var at the script's own fallback value. Require a non-default value for the other var so each case is independently observable.

**Why:** When harness default == script default, a partial-unset test produces the same assertion as the both-unset test — tautological, proving neither var's fallback fires independently.

**Where:** Sweep 2.15 (fix column).
