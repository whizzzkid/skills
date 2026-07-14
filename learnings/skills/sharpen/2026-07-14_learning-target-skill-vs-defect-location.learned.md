---
skill: wk-sharpen
date: 2026-07-14
type: pattern
severity: low
---

A learning filed under skill X can describe a defect whose text lives in skill Y; fold both.

**What happened:** A learning was filed under `gh` (the API-mechanics home), but the actual over-generalized claim it corrected ("404s for *all* ops") lived verbatim in a *different* skill's SKILL.md (`pr-resolve` Step 3). Grepping only the filed skill's tree found nothing to fix; a cross-skill grep of the core subject term surfaced the real defect location.

**Root cause:** Step 2 ("Read the Full Skill") scopes to the skill the learning names. When a learning states a general API principle, the wrong instance can be encoded in any skill that touched that API — not just the one filed.

**Suggested fix:** During distill, grep the learning's core subject term across the whole `skills/` tree, not just the filed skill. Fold the principle into the API-mechanics home skill AND correct every over-general instance found elsewhere in the same pass.
