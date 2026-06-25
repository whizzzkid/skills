---
skill: wk-adversarial-review
date: 2026-06-25
type: correction
severity: high
---

Multi-branch error messages must be keyed on the variable that actually failed, not a proxy variable — message branches keyed on the wrong discriminant fire misleading messages on orthogonal failures.

**What happened:** A skill guard had two branches keyed on whether STDERR_OUTPUT was empty or non-empty. When FINDINGS_PATH was successfully parsed (non-empty, format was fine) but the file didn't exist on disk, the "non-empty stderr" branch fired "output format may have changed" — which was wrong. The format was fine; the file was simply absent.

**Root cause:** The two conditions (parse failure and file-missing) were collapsed into one "empty or file missing" guard, then branched on a proxy variable (stderr emptiness) rather than on the actual failure mode (parse result vs file existence).

**Suggested fix:** Each distinct failure mode gets its own condition and message: (1) parse failed + stderr non-empty → format change warning; (2) parse failed + stderr empty → no-output message; (3) parse succeeded + file missing → file-not-found message. Never use a proxy variable when the discriminant is available directly.
