---
skill: wk-adversarial-review
date: 2026-06-19
type: correction
severity: high
---

Test global state restoration — log.SetOutput(nil) corrupts subsequent log calls and causes hangs

**What happened:** A new test file used `log.SetOutput(&buf)` to capture log output and `t.Cleanup(func() { log.SetOutput(nil) })` to restore afterward. This set the global logger's output writer to `nil`. A subsequent test in the same binary that called `log.Printf` (in an unrelated package) hung for the duration of the test timeout (10 minutes) because the global logger's `l.out` field was nil, causing write-to-nil behavior in `log.(*Logger).output`.

**Root cause:** `log.SetOutput(nil)` sets the global standard logger's output to nil rather than restoring it to `os.Stderr`. Any subsequent `log.Printf` call in the same binary will attempt to write to a nil `io.Writer`, causing a hang or nil-pointer dereference. The test timeout fires before the affected test goroutine is allowed to progress past the nil-write, making it appear that the unrelated test is slow.

**Suggested fix:** When redirecting the global logger in tests, always save and restore the original writer:
```go
orig := log.Writer()
log.SetOutput(&buf)
t.Cleanup(func() { log.SetOutput(orig) })
```
Never use `log.SetOutput(nil)` — it does not restore stderr; it sets the output to nil. The adversarial review should add a sweep for `log.SetOutput(nil)` in test files as a blocker-class finding: it corrupts global state shared across all tests in the binary and causes hard-to-diagnose timeout failures in unrelated tests.
