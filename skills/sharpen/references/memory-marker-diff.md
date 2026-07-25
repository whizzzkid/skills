---
class: principle
---

**Rule** — Normalize both sides before diffing the memory listing against
`.distilled-memories`: collapse repeated slashes (`sed 's#//#/#g'`) and `sort -u` each
side, then `comm`.

**Why** — `comm` does exact string matching, so the listing and the marker must share one
path form; a trailing-slash glob yields `dir//file.md` and silently mismatches every
entry. A result where *every* memory reads un-distilled is a probable format mismatch,
not a real backlog — sanity-check it before processing.

**On a refused invocation** — drop only the blocked element (stage both lists in-repo);
never swap the comparison primitive, or the substitute's tooling difference reads as real
backlog.

**Where** — wk-sharpen batch mode, Source 3 (global memory files).
