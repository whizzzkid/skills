---
skill: wk-buildkite
date: 2026-11-03
type: gap
severity: medium
verified-against-source: n/a
---

A CI watch script with hardcoded build numbers needed hand-editing and re-arming after every push.

**What happened:** After each push the agent looked up the new build number, edited the watch script's constants by
hand, and restarted the monitor, which also expired every few minutes. Each cycle added a manual step where a mistake
(a stale number, a missed re-arm) would silently watch the wrong build or nothing.

**Root cause:** The skill describes one-shot status checks and forbids foreground polling, but gives no reusable
watch recipe. The agent improvised one that did not resolve its own target.

**Suggested fix:** Add a watch recipe to the monitoring section: resolve the latest build for the current commit SHA
inside the script, track any triggered downstream pipeline build by branch, print on every state change, tolerate
transient API read failures, and run it as a persistent monitor so it need not be re-armed.
