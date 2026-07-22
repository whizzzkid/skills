---
skill: wk-sitrep
date: 2026-07-22
type: preference
severity: low
---

When opening a local file for the user to review or edit, prefer `zed <path>`
over `open <path>` (the macOS default handler — Preview for HTML, vim for
markdown) or `vim`.

**What happened:** Materialized from the `feedback_use_zed_editor` memory during
a batch sharpen. The user's editor is Zed; `open`/`vim` picked the wrong handler
for the markdown/HTML review files (`morning.md`, `evening.md`, `morning.html`)
produced by the former goodmorning/goodevening skills.

**Disposition — one-off, no live skill surface:** No SKILL.md in the suite opens
a local `.md`/`.txt` file via an editor. The current sitrep skill is
browser-based (SilverBullet) and opens a URL, not a file; the goodmorning /
goodevening skills the preference names are retired. Every `open` in the suite
targets a URL or HTML-meant-to-render, where a browser is correct, not zed.
Folding into any SKILL.md today would be a dead instruction (wk-sharpen forbids
bloat), so it is not folded. Retained as a user memory; captured here for the
sitrep lineage. If file-opening returns to sitrep, use `zed` for markdown/text
and a browser for HTML meant to render.
