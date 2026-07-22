---
class: one-off
---

**Scenario:** A skill opens a local file for the user to review or edit (e.g. a
generated markdown or HTML report).

**Symptom:** `open <file>` launches the macOS default handler — Preview for HTML,
vim for markdown — which is not the user's editor; `vim` is likewise unwanted.

**Fix:** Use `zed <path>` for markdown/text files meant to be read or edited; use
a browser for HTML meant to render (not zed, which would show source).

**Why not promoted:** No live skill opens a local file in an editor. The current
sitrep skill renders in the browser via SilverBullet and opens a URL; the
goodmorning / goodevening skills that opened `morning.md` / `evening.md` /
`morning.html` are retired. Folding into any SKILL.md today would be a dead
instruction. Retained as a user memory; distilled here for lineage in case
file-opening returns.
