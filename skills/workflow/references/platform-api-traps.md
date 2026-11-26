---
class: principle
---

# Platform-API traps

(a) Before enabling a convenience API that automates a user-facing action,
verify it does not suppress the event handler for that action — many take
exclusive ownership silently.

(b) Calls requiring user-gesture context must fire synchronously within the
handler's call stack — `await` before the call breaks the chain; the API
silently drops the request.

(c) Process-match waits differ per OS: procps `pgrep` (Linux) skips only
itself, so the waiter's own wrapper shell matches; macOS/BSD `pgrep` skips
itself and its ancestors but not sibling waiters. Either way a process-match
wait loop can outlive its target — wait on the completion notification.
