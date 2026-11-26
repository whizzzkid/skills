---
skill: wk-playwright
date: 2026-11-26
type: correction
severity: medium
verified-against-source: n/a
---

With Playwright, regenerate every screenshot after each fix: a capture older than the last code change is stale evidence.

**What happened:** Playwright screenshots of several UI states (full page, hover, post-click) were captured for a PR.
A later fix changed the rendering, but only some captures were retaken. The user opened the rest, saw the pre-fix look,
and concluded the fix had not landed.

**Root cause:** Screenshots were treated as one-time evidence rather than artifacts that must match the current code.
Captures were taken ad hoc, call by call, so a re-shoot meant picking files by hand, and some got missed.

**Suggested fix:** Whenever Playwright is in use and a fix lands:
- Re-run the capture for every screenshot already produced or referenced (PR body, docs, hand-off), overwriting the
  files, before claiming the fix or sharing images.
- Keep all captures in one re-runnable script (navigate, interact, screenshot each state), so a re-shoot is a single
  call.
- Pair each re-shoot with a measured assertion of the fixed property (e.g. `getBoundingClientRect()` for size,
  computed style for color), since a screenshot alone can hide small drift.
- Delete superseded captures, so no stale file can be attached by mistake.

Candidate for a new model-invocable `wk-playwright` skill, together with the existing hover-timing and screenshot-path
findings.
