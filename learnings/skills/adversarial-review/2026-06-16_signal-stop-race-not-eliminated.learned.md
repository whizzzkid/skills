---
skill: wk-adversarial-review
date: 2026-06-16
type: pattern
severity: medium
---

signal.Stop narrows but does not eliminate a buffered signal channel race

**What happened:** A review comment noted a race where a SIGINT could cause os.Exit(1) on a successfully-completed run. The fix moved signal.Stop earlier (before the error check), and the fix comment originally said this "eliminates" the race. The adversarial review caught that the comment overstated the guarantee.

**Root cause:** signal.Stop unregisters the channel from future signal deliveries but does NOT drain the channel buffer. If a SIGINT was already queued in the buffered channel (e.g. the goroutine received it but hasn't dequeued yet, or the OS delivered it just before Stop was called), the goroutine will still dequeue and execute cleanup + os.Exit(1). The window is narrower after the reorder but not zero.

**Suggested fix:** When reviewing signal-handler races involving buffered channels, flag any comment claiming the race is "eliminated" — the correct framing is "narrows the window" or "reduces the race window". True elimination requires either (a) a done channel the goroutine checks before calling os.Exit, or (b) an atomic flag set before signal.Stop so the goroutine's exit path guards on it.
