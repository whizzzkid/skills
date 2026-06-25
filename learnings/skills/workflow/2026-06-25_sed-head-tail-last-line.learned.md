---
skill: wk-workflow
date: 2026-06-25
type: correction
severity: high
---

Use `tail -1` (not `head -1`) when extracting the meaningful log line from a stream where the target line is always emitted last.

**What happened:** A pipeline used `sed -n 's/.*pattern → //p' | head -1` to extract a path from a log stream. If any earlier stderr line contained the same `pattern →` substring (e.g., a warning about a config containing that text), `head -1` would pick the wrong line. The real log line is always emitted last by the process.

**Root cause:** `head -1` returns the first match; when earlier output can contain the same pattern, this silently picks the wrong value. The `sed -n ... p` already filters to matching lines only, so `tail -1` picks the last match — which is the intended target when the emitter writes the canonical line last.

**Suggested fix:** For any `sed -n 's/.*marker//p' | head -1` that targets a process's final summary line, use `tail -1`. Only use `head -1` when the first occurrence is authoritative (e.g., a header line).
