# wk-preso

**Version:** 2026.08.18-214753

Interactive HTML slide deck generator — publishes a self-contained, accessible
presentation as an Artifact with full keyboard navigation, dark/light theming,
auto-transition, and deep linking.

## Triggers

- Direct: `/wk-preso <topic>`
- Auto: "create a presentation", "make slides", "build a deck", "powerpoint",
  "preso", "slide-deck"

## Key Features

- **Dark/light mode** with system-preference default and manual toggle
- **Hash-based deep linking** — `#slide:<N>;heading:<slug>;auto:<on|off>`
- **Auto-transition** calibrated to reading speed (200 WPM), pausable
- **Keyboard navigation** — arrows, Page keys, Home/End, Space to pause
- **Hamburger menu** sidebar for slide titles
- **Progress bar** and slide numbering
- **Interactive Mermaid diagrams** with animated entry
- **Time-aware agendas** using the viewer's local clock
- **WCAG AA accessible** — focus management, aria-live, contrast, reduced-motion
- **Author branding** — whizzzkid avatar on every slide, linked to
  [whizzzkid.dev](https://whizzzkid.dev)
- **Futuristic, subject-appropriate color themes** with subtle CSS animations

## Flow

1. Gather content from user topic/outline
2. Load [artifact-design](../arch-review/README.md) for design calibration
3. Author full HTML slide deck (inline CSS/JS, no external deps)
4. Embed author avatar as base64 data URI
5. Publish via Artifact tool
6. Report link and slide count

## Integration

- Loads `artifact-design` skill before writing
- Uses [wk-curl](../curl/README.md) patterns for avatar fetch
- Invokes [wk-learn](../learn/README.md) post-completion
