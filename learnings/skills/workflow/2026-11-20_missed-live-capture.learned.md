---
skill: wk-workflow
date: 2026-11-20
type: gap
severity: low
verified-against-source: n/a
---

Live learning capture fired for the first self-caught error but not for three later ones; only the retro recovered them.

**What happened:** Four self-caught errors came up in one session. A wk-learn file was written in the same response for the first one only. The other three were captured for the first time at retro: a guessed tracker URL, a watch loop that never matched its build, and an API 422. Capture timing was live 1, reconstructed 3.

**Root cause:** In each case, the fix was applied immediately and work moved on. The mid-flow repair felt routine, so the live-capture rule did not trigger.

**Suggested fix:** Treat every "I fixed my own mistake" edit as a capture trigger: a corrected PR body, a re-armed or replaced watcher, or a fallback route after an API error. Pair the `wk-learn` call with the repair in the same response.
