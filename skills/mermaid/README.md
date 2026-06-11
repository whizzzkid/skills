# wk-mermaid

> Author Mermaid diagrams that render correctly on GitHub — the strictest common target.

**Version:** `2026.06.11-213638`

## Invocation

| Mode | Trigger |
|------|---------|
| User-invocable | `/wk-mermaid` — audit mermaid blocks in the current file/repo |
| Model-invocable | automatic: whenever the agent authors or edits a ```mermaid block |

## How It Works

```mermaid
flowchart TD
    A["Author or edit a mermaid block"] --> B["Step 1: Pick a supported type<br/>flowchart · sequence · class · state · ER"]
    B --> C["Step 2: Line breaks use &lt;br/&gt;, never backslash-n"]
    C --> D["Step 3: Quote labels with special chars<br/>parens, colons, pipes, quotes"]
    D --> E["Step 4: Drop GitHub-sanitized constructs<br/>no click, no raw HTML beyond br"]
    E --> F{High-stakes diagram?}
    F -->|yes| G["Step 5: Open GitHub blob in browser<br/>screenshot, confirm render"]
    F -->|no| H["Step 5: grep block for backslash-n and click"]
    G --> I["Diagram renders on GitHub"]
    H --> I
```

## Noteworthy

- **Literal `\n` is the #1 GitHub mermaid failure** — it renders as two visible characters, not a line break. Use `<br/>` (or `<br>`); grep every block for `\n` before writing.
- **GitHub sandboxes Mermaid** — `click`/JS interactivity is stripped and raw HTML beyond `<br/>` is sanitized, so diagrams that work on mermaid.live can still fail here.
- **Quote any label with punctuation** beyond letters, digits, spaces, and hyphens — unquoted `()`, `:`, `|`, `{}` break the parse; node IDs stay alphanumeric while human text lives in the quoted bracket label.
- **Validation is part of authoring** — grep for `\n`/`click`, and for high-stakes diagrams open the GitHub blob URL in a browser to confirm the render rather than a syntax-error box.
- Defers broad markdown formatting (width, headings, link checks) to [wk-markdown](../markdown/README.md); this skill owns mermaid render-correctness only.
