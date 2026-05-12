---
skill: wk-workflow
date: 2026-05-12
type: gap
severity: medium
---

Grep for existing implementations before adding a new one in large mixed-content files.

**What happened:** A new feature implementation was added to a large ERB file without first searching the file for an existing version of the same function. A pre-existing duplicate with incorrect logic was already present and silently shadowed the new implementation. The adversarial reviewer caught it; the author missed it entirely.

**Root cause:** The workflow's "prefactor probe" focuses on lifting shared patterns into helpers but does not explicitly call out the case of large single-file implementations where a stale or incorrect version of the same feature may already exist.

**Suggested fix:** Add a rule to Phase 2 (Implement): before adding any function, event handler, or initialization block to a large file (>200 lines, especially mixed HTML+JS templates), grep the file for the function/feature name first. If a match is found, evaluate whether to remove/replace it in the same commit rather than adding alongside it.
