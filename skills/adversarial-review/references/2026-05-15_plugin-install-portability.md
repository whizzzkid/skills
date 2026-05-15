---
class: principle
---

- **Rule:** When the diff touches `SKILL.md` or `.claude-plugin/plugin.json`, sweep the SKILL.md body for relative paths rooted at the publishing-repo layout (e.g., `Read("skills/.../*.md")`); require `${CLAUDE_PLUGIN_ROOT}/`, inline content, or a pinned upstream `WebFetch`. Blocker until resolved.
- **Why:** Plugin paths that work in the authoring repo fail silently in consumer repos — the file simply doesn't exist there. Authoring-repo CI never surfaces the failure; it only fires at install time in the consumer's session.
- **Where:** Step 2 mechanical sweeps → new Sweep 2.16 "Plugin install portability", placed after 2.15 Workstyle pass.
