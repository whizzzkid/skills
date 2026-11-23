---
skill: wk-pr-review
date: 2026-11-23
type: correction
severity: medium
verified-against-source: n/a
---

Always flag opaque, agent-generated identifiers that leak into human-facing artifacts.

**What happened:** A PR added an LLM check whose findings cite undocumented card IDs (prefix-batch-number codes) and internal "shape N" / "rule N" numbering. The review didn't flag them until the user asked why the change had such odd references, then told the agent to always call these out.

**Root cause:** The skill has no lens for readability of agent-authored names: IDs, codes and numbering produced by a generation or labeling pipeline that mean nothing to a human reader and aren't defined in the repo.

**Suggested fix:** Add a Phase 3/4 sweep: grep the diff for agent-esque identifiers (code-like IDs, batch/round numbers, references to undefined numbered lists or versions) that reach a human surface (posted comments, docs, prompts whose output humans read). Each undefined one gets a `suggestion:` asking for a human-readable reference or a legend.
