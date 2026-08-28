---
class: principle
---

# False-positive class suppression over severity downgrade

**Rule** — When a review finding is a false positive because its claim class is
unverifiable (e.g., "this name doesn't exist" without ability to confirm),
suppress the specific finding class; never reach for a broad severity downgrade.

**Why** — A severity downgrade treats "reduce noise" as a volume problem; the
real issue is that one class of claims cannot be verified. Lowering severity
mutes real findings in the same band. Suppressing the class removes only the
unresolvable noise.

**Where** — `SKILL.md` → Phase 2 → Edit-scope pre-flights → *False-positive
scoping*.
