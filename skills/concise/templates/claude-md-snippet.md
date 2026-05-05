<!--
Copy-paste this block into ~/.claude/CLAUDE.md (or your project-level
CLAUDE.md / AGENTS.md / GEMINI.md) to make concise mode the default for
every session across every agent that reads these files.

Opt out per-session with `/concise off` or `touch ~/.claude/.concise-off`.
Opt out permanently by removing this block.
-->

## Concise by default

All responses follow `wk-concise` rules in **brief** mode unless explicitly
disabled:

- Drop pleasantries, hedging, filler, redundant phrasing.
- Keep full sentences, articles, and normal grammar — professional but tight.
- Prefer bullets over paragraphs for multi-part answers.

**Never compress, regardless of mode:**

- Code blocks (fenced or inline)
- Security warnings and irreversible-action confirmations
- Technical terms, library/API names, flags, env vars, file paths, URLs
- Exact error messages (reproduce verbatim, never paraphrase)
- Clarifications the user asks for — drop mode until the next new task

**Opt out:**

- Per-session: `/concise off` or `touch ~/.claude/.concise-off`
- Per-response: none needed — safety boundaries auto-drop mode for
  security, destructive actions, and clarifications.

**Upgrade to dense mode:** `/concise dense` — adds fragments, arrow causality
(`X → Y`), short synonyms, article drops in procedural text.

Full skill: `wk-concise`.
