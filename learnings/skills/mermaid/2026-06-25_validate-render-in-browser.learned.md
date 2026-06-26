---
skill: wk-mermaid
date: 2026-06-25
type: gap
severity: high
---

Always open the rendered markdown page in a browser to validate mermaid diagrams before committing.

**What happened:** A mermaid `sequenceDiagram` with an `opt` block was added to a spec file. The syntax looked correct in the diff and the commit went through, but the diagram failed to render in the browser (GitHub blob view), breaking the spec page entirely.

**Root cause:** Mermaid syntax errors are invisible in `git diff` and plain-text review. The only way to catch them is to render the diagram. A newly added `opt` block in a `sequenceDiagram` introduced a parse error that only surfaced when the rendered page was opened.

**Suggested fix:** After any `Edit`/`Write` that adds or modifies a mermaid code block, before committing:
1. Push the changes (or use a local preview tool).
2. Open the rendered page in a browser — use the playwright MCP or browser MCP to navigate to the GitHub blob URL (e.g. `https://github.com/{org}/{repo}/blob/{branch}/{file}.md`).
3. Visually confirm the mermaid diagram renders without an error banner.
4. Only commit if the diagram renders correctly.

This applies to all mermaid diagram types: `sequenceDiagram`, `flowchart`, `graph`, `classDiagram`, `stateDiagram-v2`, etc.
