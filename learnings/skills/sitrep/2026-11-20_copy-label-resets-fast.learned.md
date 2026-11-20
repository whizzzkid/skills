---
skill: wk-sitrep
date: 2026-11-20
type: gap
severity: low
verified-against-source: yes
---

The standup copy verification reads the button label too late: it resets to "Copy" after 1.5 seconds.

**What happened:** The click tool dispatched the copy, but the following separate evaluate call returned "Copy", so
neither the "Copied ✓" state nor the payload could be confirmed and the check had to be reported as unverified.

**Root cause:** The handler restores the label with a 1500 ms timeout; two sequential tool round-trips exceed it.

**Suggested fix:** In `references/standup-copy-block.md`, install a `MutationObserver` or a clipboard-write spy in an
evaluate call before the click, then read the recorded states afterwards, instead of reading the label post hoc.
