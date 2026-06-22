---
skill: wk-adversarial-review
date: 2026-06-19
type: gap
severity: high
---

Log-filter helpers silently break when failure callsites use a different format than the filter expects.

**What happened:** A `warnWriter` was introduced to pass `WARNING:`-prefixed log lines to stderr while discarding INFO noise. However, per-check and per-validator failure messages were emitted via a session-scoped `logf` helper that produces `[session-name] message` format — no `WARNING:` token. The filter silently dropped exactly the diagnostics its own doc comment promised to surface.

**Root cause:** The review skill did not audit whether all failure-path call sites actually emit the token the filter matches on. It found the filter implementation correct in isolation but missed that `logf` (used at executor-failure and validator-failure sites) strips the log prefix convention, leaving those paths invisible to the filter.

**Suggested fix:** Add a sweep rule: when a diff introduces a log-level filter (a custom `io.Writer` that routes by string content), grep all failure-path log calls in the affected package for the expected token. Any site using a helper that reformats the message (e.g., `[session]`-prefixed helpers) is a silent gap. Surface as a blocker — the filter's own comment is load-bearing documentation for users.
