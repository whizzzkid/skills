---
class: principle
---

**Rule:** A bash fake/stub that branches on argument or URL content (`if [[ $arg == *pattern* ]]`) must end each matched branch with an explicit terminal `exit`/`return` returning that branch's own semantically-correct fallback. A matched branch with no terminal exit before its closing `fi` falls through to the sibling branch's response.

**Why:** When a conditional path's branch has several independent early-exit sub-conditions but no catch-all default, a test that omits the branch-specific params hits none of them and falls through to the sibling's `echo …; exit 0`. The test then passes by exercising the wrong path (e.g. a beta-unavailable case silently returns the stable CDN URL), so the spec is green while asserting nothing about the path it names.

**Where:** Sweep 2.47 in `SKILL.md` Step 2 — for every `if [[ url == *pattern* ]]` in a bash fake, verify the block has an explicit `exit` before the closing `fi`; the fallback should match the branch's semantics (`echo '[]'; exit 0` for a not-yet-available path), never fall through.
