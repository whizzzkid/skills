---
class: principle
---

# Unmatched globs abort optional config probes

**Rule** — Enumerate optional filesystem candidates as data, then match their basenames. Never place an optional bare
glob in a loop header: expansion occurs before the loop and a shell with fatal unmatched globs aborts the whole probe.

**Why** — A config-discovery loop failed before checking any candidate when one wildcard family had no matches. A
shell-specific null-glob mode made that run pass but violated the existing cross-shell rule.

**Where** — The style-authority probe now uses shell-neutral enumeration. The shell-portability rule was escalated
from baseline to `Important` after this repeat violation.
