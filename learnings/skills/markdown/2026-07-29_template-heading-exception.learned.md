---
skill: wk-markdown
date: 2026-07-29
type: gap
severity: low
verified-against-source: yes
---

Let artifact-specific templates override generic heading rules.

**What happened:** Structured learning and retrospective templates intentionally prescribe
frontmatter or an H2 entry without an H1, conflicting with the generic requirement that every
Markdown file contain exactly one H1.

**Root cause:** The Markdown skill states its heading rule as universal and does not exempt exact
templates owned by another active skill.

**Suggested fix:** State that an artifact-specific template takes precedence over generic heading
hierarchy rules, including its deliberate absence of an H1.
