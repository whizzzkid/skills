---
skill: wk-adversarial-review
date: 2026-06-10
type: gap
severity: medium
---

Ported download snippets with `curl -u $VAR1:$VAR2` often carry undocumented credential variable names.

**What happened:** A download code block was ported from another branch into README.md. It used `curl -u "${CLOUDSMITH_USER}:${CLOUDSMITH_API_KEY}"` but neither variable was defined, explained, or sourced anywhere in the doc. Users copy-pasting the snippet would get a silent auth failure.

**Root cause:** The porting review focused on structural correctness (filter logic, package naming) and missed that credential variable names which were implicit in the source context become opaque in a new doc context. Sweep 2.8 (cross-doc enumeration) catches named flags and symbols but does not specifically probe for unexplained env var names in shell code blocks.

**Suggested fix:** Add a sweep step (or extend 2.8) for shell code blocks in docs: for every `$VAR` or `${VAR}` used in a `curl -u`, `Authorization:`, or auth-passing pattern, verify the variable is defined or annotated (inline comment, prose above the block, or a dedicated "Prerequisites" section) within the same doc. Flag missing explanations as `suggestion`.
