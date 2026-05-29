---
skill: wk-arch-review
date: 2026-05-29
type: surprise
severity: high
---

Check systems using frontmatter to declare file scope may not enforce it in the engine — verify the runtime dispatch before treating frontmatter as a hard filter.

**What happened:** A design spec described `file_types:` frontmatter as controlling which files a check runs on. Reading the engine code (`context_prep.rb`) revealed no dispatch logic at all — every check skill and the full PR diff are packaged into one LLM context, so "file-type gating" is advisory prose the model must honor.

**Root cause:** Architectural model drift between the spec and the implementation — the spec was written describing a capability the engine doesn't have.

**Suggested fix:** When reviewing a check/skill system, always verify how frontmatter is consumed by the runtime before accepting doc claims about dispatch behavior. Add this as a lens-C (assumptions) probe for systems with declared config metadata.
