---
skill: wk-learn
date: 2026-11-17
type: gap
severity: low
verified-against-source: n/a
---

A failed negative control is a self-caught error and must trigger live capture.

**What happened:** A regression spec that stayed green with the fix defeated was rewritten on the spot, but the
learning was only written during the retro scan.

**Root cause:** The live-capture trigger list names corrections and verifier refutations; a negative control that
"fails to fail" reads as routine test iteration, not as an "I was wrong" moment.

**Suggested fix:** Add "a negative control that stays green (vacuous test)" to the explicit live-capture triggers.
