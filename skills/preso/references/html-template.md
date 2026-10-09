# Slide Deck HTML Template Requirements

Every requirement below is mandatory — the deck is not done until all are met.

## Layout and Navigation

- Each `<section>` is one slide; assign `data-slide="N"` (1-indexed).
- Slide numbering visible on every slide: `N / total`.
- Arrow buttons (prev/next) fixed at bottom edges of the viewport.
- **Hamburger menu** (top-left) — slide-title sidebar overlay; clicking a title jumps to that slide.
- **Progress indicator** — thin bar at top showing `currentSlide / total` as filled percentage.
- **Keyboard navigation** — left/right or PageUp/PageDown cycle slides; Escape closes menus; Home/End jump to first/last; Space toggles auto-play pause. Announce via `aria-live` on slide change.

## Deep Linking via URL Hash

- Hash format: `#slide:<N>` or `#slide:<N>;heading:<slug>`.
- On load, parse hash and jump to that slide/heading.
- On every slide transition, update `location.hash` without triggering a reload.
- Multiple headings within a slide each get an `id` matching their slug.
- **Auto-play state** in hash: `#slide:<N>;auto:<on|off>`.
- `popstate` handler restores slide from hash on back/forward.

## Auto-Transition

- Reading time per slide: `wordCount / 200 * 60 * 1000` ms (200 WPM), minimum 4s, maximum 30s.
- Auto-advance ON by default; visible play/pause toggle near progress bar.
- Pausing updates hash to `auto:off`; resuming sets `auto:on`.
- Any manual navigation pauses auto-play.

## Dark/Light Theme

- Default to system preference (`prefers-color-scheme`).
- Sun/moon icon button in top-right corner toggles manually.
- Toggle sets `data-theme` on `<html>` and persists in `localStorage`.
- On load: check `localStorage` first; fall back to system preference.
- Light palette on `:root`; redefine under `@media (prefers-color-scheme: dark)` guarded as `:root:not([data-theme="light"])`; redefine under `:root[data-theme="dark"]`.

## Color Theme and Animation

- Subject-appropriate palette with accent gradients.
- Slide transitions use subtle CSS animations (fade or slide, <=300ms).
- Headings may use subtle gradient text or glow effects.
- Diagrams and data visualizations should have animated entry.

## Time-Based Content

- Agenda with times: read user's local clock, highlight current/next agenda item.
- Display small live clock in corner if agenda times present.

## Diagrams

- Inline SVG or `<pre class="mermaid">` blocks (Artifacts render Mermaid natively).
- Interactive where possible: hover highlights, click-to-expand, tooltips.
- Animate diagram entry (fade-in paths, progressive reveal).

## Accessibility

- All slides: `role="region"` and `aria-label="Slide N: <title>"`.
- Focus management: on slide change, focus moves to new slide's heading.
- Skip-to-content link at top.
- Color contrast >= 4.5:1 (WCAG AA).
- All interactive elements focusable and keyboard-operable.
- `aria-live="polite"` region announces current slide number.
- Images have `alt` text; decorative images use `alt=""` and `aria-hidden`.
- Reduced-motion: wrap animations in `@media (prefers-reduced-motion: no-preference)`.

## Author Branding

- Every slide, bottom-right: circular avatar (32x32px) linked to author's site.
- Avatar URL: `https://avatars.githubusercontent.com/u/1895906`
- Link target: `https://whizzzkid.dev`
- Embed avatar as `data:` URI (Artifact CSP blocks external images) — `curl` + base64-encode inline.
- `alt="whizzzkid"`; link opens in new tab.

## Responsive Design

- Relative units, flexbox/grid, `max-width: 100%` on media.
- Slides scale to viewport; no horizontal body scroll.
- Wide content (tables, code) gets `overflow-x: auto`.

## Self-Contained

- All CSS/JS inline — no external CDN, no external stylesheets (except Google Fonts if desired).
- No `<!DOCTYPE>`, `<html>`, `<head>`, or `<body>` tags — Artifact wraps those.
- Include a `<title>` tag at the top (Artifact scans first 8KB).
