---
class: principle
skill: wk-buildkite
date: 2026-06-23
---

**Rule**

When starting background CI monitoring after a push, immediately report three
things — the build URL, the current failing step (if known), and the next
diagnostic action — never just "monitoring in background."

**Why**

A bare "watching CI" leaves the user unable to tell whether the failure is
already identified or still being discovered, forcing an interrupt ("what are you
checking?").

**Where**

"Monitoring Builds After Push" section, HARD RULE beside the never-foreground-poll
rule.
