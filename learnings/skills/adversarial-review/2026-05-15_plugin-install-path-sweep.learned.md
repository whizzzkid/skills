---
skill: wk-adversarial-review
date: 2026-05-15
type: gap
severity: high
---

Plugin skill SKILL.md paths must resolve in consumer repos, not just the publishing repo.

**What happened:** A Claude Code plugin's SKILL.md used `Read("skills/checks/*.md")` paths that resolve correctly inside the publishing repo but fail silently when the plugin is installed in any other repo. The adversarial review caught this as a blocker via the fresh-context subagent.

**Root cause:** The mechanical sweeps in wk-adversarial-review don't include a plugin-install-portability check. The existing sweeps target code correctness, not skill/plugin portability.

**Suggested fix:** Add a sweep to wk-adversarial-review: when the diff includes a `SKILL.md` or `.claude-plugin/plugin.json`, scan the SKILL.md body for `Read(` calls whose paths are relative to the publishing repo root (not `${CLAUDE_PLUGIN_ROOT}/`). Flag each as a blocker unless a WebFetch fallback or inline content is also present.
