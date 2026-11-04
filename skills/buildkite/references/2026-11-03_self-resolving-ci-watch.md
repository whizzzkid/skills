---
class: principle
---

# A CI watch resolves its own target

- **Rule:** A background watch re-resolves its target every poll — pushed branch tip via `git ls-remote`, then the
  newest build for that SHA via `bk build list --commit` — and runs once with `run_in_background: true`. A triggered
  downstream pipeline gets a second instance with its own slug.
- **Why:** A watch script with a hardcoded build number needed hand-editing and re-arming after every push, and its
  monitor expired every few minutes. Each manual cycle could silently watch a stale build or nothing.
- **Verified:** The recipe in `SKILL.md` was extracted verbatim and driven against stub `git`/`bk` binaries: it
  followed a push from one SHA to the next (no build yet → `queued`, then the new build), exited 0 on `passed`, 1 on
  `failed`, and 2 with a printed line on an unparsable API response.
- **Rejected:** "Tolerate transient API read failures" — silently re-polling an unparsable read is exactly what the
  parse-proof HARD RULE forbids. The loop exits 2 with a printed line; relaunch is a visible event.
- **Where:** [`wk-buildkite`](../README.md) → Monitoring after push.
