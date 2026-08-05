---
skill: wk-workflow
date: 2026-08-04
type: correction
severity: low
verified-against-source: yes
---

Run the architecture-artifact detector before editing a spec.

**What happened:** The architecture review gate ran after the spec change had already been committed
and pushed, even though the workflow identified specs as mechanically reviewable artifacts.

**Root cause:** The implementation pre-flight did not classify the documentation target before the
first edit.

**Suggested fix:** Before editing, classify every planned path and run the architecture detector when
any spec, ADR, design, RFC, or plan path is present.
