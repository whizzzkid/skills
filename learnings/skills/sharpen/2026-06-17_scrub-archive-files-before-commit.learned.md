---
skill: wk-sharpen
date: 2026-06-17
type: gap
severity: medium
---

Run the prohibited-term/overfit scrub on archived learning and retrospect files, not just SKILL.md and reference edits.

**What happened:** A commit was blocked by the prohibited-term hook because an archived learning and a retrospect file (renamed to .learned.md and committed as the processed-state record) contained an internal tool name. The overfit scan had only covered the SKILL.md and reference edits.

**Root cause:** The mechanical overfit scan in Step 5 targets the proposed skill edits and reference files; it does not cover the learning/retrospect archive files that also enter the public repo via the .learned.md rename.

**Suggested fix:** Before committing, scrub every staged learning and retrospect archive file for prohibited terms (internal tool/project/service names, org/employer tokens) and replace with generic placeholders — extend the Step 5 overfit scan to the archive files, not only the skill edits.
