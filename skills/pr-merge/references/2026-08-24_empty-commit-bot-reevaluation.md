---
class: principle
---

# Empty-commit bot re-evaluation — already covered

**Rule** — When a bot review is COMMENTED (not APPROVED) after all threads are
resolved, push an empty commit to trigger re-evaluation.

**Why** — Some bots only re-evaluate on new pushes, not on thread resolution events.

**Where** — `SKILL.md` → Step 3 → `reviewDecision == "REVIEW_REQUIRED"` handling
already documents this pattern: "push empty commit (`git commit --allow-empty`) to
trigger re-evaluation; re-run Step 3."

Classification: `already-covered` — the existing Step 3 bullet matches the learning
exactly. No edit needed.
