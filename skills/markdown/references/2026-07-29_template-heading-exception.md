---
class: principle
---

# Artifact templates override generic heading rules

**Rule** — preserve the exact Markdown heading shape prescribed by another active skill, including a deliberate
absence of H1; apply generic heading hierarchy only where the template is silent.

**Why** — structured artifacts can use frontmatter or an H2 entry as their intentional root. Inserting an H1 to
satisfy a generic rule breaks the owning template instead of improving the document.

**Where** — `SKILL.md` → Heading Hierarchy. The active learning and retrospective templates were checked and both
intentionally omit H1.

**Verification** — the precedence rule and README mirror explicitly retain deliberate no-H1 forms.

**Budget** — body `3991 + 231 = 4222` bytes, leaving 20,354 bytes. Full-skill audit wrapped one pre-existing
overlong prose line; measured cleanup was 0 bytes because wrapping added only formatting bytes.
