---
name: wk-preso
description: >-
  Use when creating a presentation, slides, powerpoint, preso, or slide-deck —
  generates an interactive, accessible, self-contained HTML slide deck published
  as an Artifact with dark/light mode, keyboard navigation, auto-transition,
  hash-based deep linking, and author branding.
argument-hint: "<topic or outline>"
user-invocable: true
model-invocable: true
disable-model-invocation: false
model: sonnet
effort: medium
group: communication
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Artifact
  - Skill
  - AskUserQuestion
metadata:
  author: whizzzkid
  version: "2026.08.18-214753"
  internal: false
  model:
    claude: claude-sonnet-4-6
    openai: gpt-5.6-terra
    google: gemini-2.5-flash
---

# Preso

Generate a fully interactive, self-contained HTML slide deck and publish it as
an Artifact.

## When to Use

- User asks to create a presentation, slides, powerpoint, preso, slide-deck,
  deck, or keynote.
- A task produces content better communicated as a slide sequence.

## Step 1: Gather Content

- If the user provided a topic or outline, use it directly.
- If vague, ask once for the key points or structure — then proceed.
- Research the topic as needed (read files, search, etc.) to build substantive
  slide content.

## Step 2: Load Design Skill

- Invoke `artifact-design` via Skill tool before writing the HTML — it
  calibrates the design investment for this deliverable.

## Step 3: Author the Slide Deck

Write a single self-contained HTML file to the scratchpad. Every requirement
below is mandatory — the slide deck is not done until all are met.

### Layout and Navigation

- Each `<section>` is one slide; assign `data-slide="N"` (1-indexed).
- Slide numbering visible on every slide: `N / total`.
- Arrow buttons (prev/next) fixed at bottom edges of the viewport.
- **Hamburger menu** (top-left `☰`) — opens a slide-title sidebar overlay;
  clicking a title jumps to that slide and closes the menu.
- **Progress indicator** — a thin bar at the top showing `currentSlide / total`
  as a filled percentage.
- **Keyboard navigation** — `←`/`→` or `PageUp`/`PageDown` cycle slides;
  `Escape` closes menus; `Home`/`End` jump to first/last; `Space` toggles
  auto-play pause. Announce via `aria-live` on slide change.

### Deep Linking via URL Hash

- Hash format: `#slide:<N>` or `#slide:<N>;heading:<slug>`.
- On load, parse the hash → jump to that slide/heading.
- On every slide transition, update `location.hash` without triggering a reload.
- Multiple headings within a slide each get an `id` matching their slug; the
  heading fragment scrolls within the slide.
- **Auto-play state** in the hash: `#slide:<N>;auto:<on|off>`.
- `popstate` handler restores slide from hash on back/forward.

### Auto-Transition

- Estimate reading time per slide: `wordCount / 200 * 60 * 1000` ms (200 WPM
  average), minimum 4 seconds, maximum 30 seconds.
- Auto-advance is ON by default; a visible play/pause toggle (▶/⏸) sits near
  the progress bar.
- Pausing updates the hash to `auto:off`; resuming sets `auto:on`.
- Any manual navigation (click, key, menu) pauses auto-play.

### Dark/Light Theme

- **Default to system preference** (`prefers-color-scheme`).
- A sun/moon icon button in the **top-right corner** toggles manually.
- Toggle sets `data-theme="dark"` or `data-theme="light"` on `<html>` and
  persists choice in `localStorage`.
- On load: check `localStorage` first; fall back to system preference.
- Define the full light palette on `:root`; redefine tokens under
  `@media (prefers-color-scheme: dark)` guarded as
  `:root:not([data-theme="light"])`; redefine again under
  `:root[data-theme="dark"]`.
- Body gets an explicit background from a token.

### Color Theme and Animation

- Choose a **subject-appropriate** palette — futuristic, clean, with accent
  gradients.
- Slide transitions use subtle CSS animations (fade or slide, ≤300ms).
- Headings and key elements may use subtle gradient text or glow effects where
  fitting.
- Diagrams and data visualizations should have animated entry (fade-in,
  draw-in).

### Time-Based Content

- If the slide content includes an agenda with times, read the user's local
  clock (`new Date()`) and highlight the current/next agenda item.
- Display a small live clock in the corner if agenda times are present.

### Diagrams

- Use inline SVG or `<pre class="mermaid">` blocks for diagrams — Artifacts
  render Mermaid natively.
- Make diagrams interactive where possible: hover highlights, click-to-expand
  nodes, tooltips.
- Animate diagram entry (fade-in paths, progressive reveal).

### Accessibility

- All slides have `role="region"` and `aria-label="Slide N: <title>"`.
- Focus management: on slide change, focus moves to the new slide's heading.
- Skip-to-content link at top.
- Color contrast ≥ 4.5:1 for text (WCAG AA).
- All interactive elements are focusable and operable via keyboard.
- `aria-live="polite"` region announces the current slide number on change.
- Images have `alt` text; decorative images use `alt=""` and `aria-hidden`.
- Reduced-motion: wrap animations in `@media (prefers-reduced-motion: no-preference)`.

### Author Branding

- On **every slide**, bottom-right corner: a small circular avatar image
  (32×32px) linked to the author's site.
- Avatar URL: `https://avatars.githubusercontent.com/u/1895906`
- Link target: `https://whizzzkid.dev`
- Embed the avatar as a `data:` URI fetched at author time (Artifact CSP blocks
  external images) — use `curl` to download, then base64-encode inline.
- `alt="whizzzkid"` on the image; link opens in new tab.

### Responsive Design

- Use relative units, flexbox/grid, `max-width: 100%` on media.
- Slides scale to viewport; no horizontal body scroll.
- Wide content (tables, code) gets `overflow-x: auto` on its container.

### Self-Contained

- All CSS/JS inline — no external CDN, no external stylesheets (except Google
  Fonts if desired).
- No `<!DOCTYPE>`, `<html>`, `<head>`, or `<body>` tags — Artifact wraps those.
- Include a `<title>` tag at the top (Artifact scans first 8KB).

## Step 4: Fetch and Embed Avatar

```bash
curl -sS -o /tmp/avatar.png "https://avatars.githubusercontent.com/u/1895906?s=64"
base64 < /tmp/avatar.png
```

Embed the result as `data:image/png;base64,...` in the HTML.

## Step 5: Publish

- Publish via Artifact tool with:
  - `favicon`: topic-appropriate emoji (e.g. `"📊"` for data, `"🚀"` for launch).
  - `description`: one-sentence summary of the deck's subject.
- On update, use the same `file_path` to redeploy to the same URL.

## Step 6: Verify

- Confirm the Artifact URL is live.
- Report the link to the user with the slide count and key features.

## Quick Reference

| Trigger | Behavior |
|---------|----------|
| `/wk-preso <topic>` | Generate and publish a slide deck on the topic |
| "make a presentation about X" | Auto-invoked, same flow |
| "create slides for Y" | Auto-invoked, same flow |

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument
(e.g., `wk-learn preso`).
