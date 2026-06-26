---
skill: wk-sharpen
date: 2026-06-26
type: gap
severity: low
---

A learning that discusses a prohibited term often contains that term as its own example, so the `.learned.md` archive trips `check-prohibited` even when the skill edit is clean.

**What happened:** Folding a learning about probe verification, the skill edit and references scanned clean, but the staged-set overfit scan (`grep -iEnf .skillprohibit $(git diff --cached --name-only)`) flagged the renamed `.learned.md`: the learning's own worked example used a live `.skillprohibit` term. Genericizing the example in the archive (replacing the real token with a neutral `a[-_]?b` → `a-b` placeholder) cleared the hook.

**Root cause:** The existing "scrub the staged learning and retrospect archive files too" rule is correct, but the failure mode is sharpest when the learning is *about* a prohibited-term mechanism — its illustrative example is the prohibited term itself. The scan-the-authoritative-staged-set rule already catches this; the lesson is to expect the archive (not the skill edit) to be the blocker for self-referential learnings.

**Suggested fix:** Already covered by the staged-set scan rule. Reinforce: when a learning's subject IS prohibited-term handling, scrub the example in the `.learned.md` before staging — confirmed the new probe rule works by feeding a plain-literal `.skillprohibit` line (regex-metachar lines won't self-match as literal input).
