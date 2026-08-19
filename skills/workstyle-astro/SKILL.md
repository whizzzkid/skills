---
name: wk-workstyle-astro
description: >-
  Astro (`.astro`, `astro.config.*`) — view transitions with ClientRouter,
  transition:persist for scroll-stable sidebars, is:inline head scripts,
  content collections, island architecture (client:* directives), and
  astro:after-swap state sync. Auto-invoked on any Astro file edit; project
  astro.config wins.
argument-hint: '[scan|check <path>]'
allowed-tools:
  - Read
  - Glob
  - Grep
model: haiku
effort: low
model-invocable: true
user-invocable: true
license: MIT
group: workflows
metadata:
  author: whizzzkid
  version: "2026.08.19-052846"
  internal: false
  model:
    claude: claude-haiku-4-5-20251001
    openai: gpt-5.6-luna
    google: gemini-2.5-flash-8b
---

# Workstyle — Astro

Enforces idiomatic Astro patterns on every `.astro` file and `astro.config.*`
the agent writes or edits. Part of the [wk-workstyle](../workstyle/README.md)
family. **Project settings are authoritative — this skill fills gaps only, never
overrides.** When `astro.config.*` or a linter governs a rule below, that config
wins; see [wk-workstyle](../workstyle/README.md) Step 0 for the
project-style-authority probe.

## When to Use

Auto-invoked whenever the agent writes or edits an Astro file. Trigger contexts:

- Writing or editing a `.astro` component, layout, or page.
- Modifying `astro.config.mjs`/`astro.config.ts`.
- Adding view transitions, islands, content collections, or client directives.

Manual: `/wk-workstyle-astro scan` (full working tree) · `/wk-workstyle-astro check <path>` (one file).

## Rules

### View Transitions

- **`<ClientRouter />` from `astro:transitions` in the layout `<head>`** to
  enable client-side navigation — without it Astro does full-document reloads.
- **`transition:persist` on elements whose DOM state must survive navigation**
  (sidebars, audio players, scroll containers). Astro replaces the entire
  `<body>` on client-side swap — unpersisted elements lose scroll position and
  local state.
- **Sync server-rendered attributes after swap.** A persisted element keeps its
  old DOM — `aria-current`, active classes, and any attribute set by the server
  goes stale. Add an `astro:after-swap` listener that reconciles
  `location.pathname` against persisted links/nav items.
- **Verify client-side swap vs full reload.** Set `window.__testMarker = true`
  before a navigation click; if it survives, swap is working. If not,
  `<ClientRouter />` is missing or misconfigured.

### Head Scripts

- **`is:inline` scripts in `<head>` re-run on every client-side navigation** —
  correct for theme-restore and other paint-blocking scripts. Without
  `is:inline`, Astro deduplicates and runs head scripts only once.
- **Never put side-effectful initialization in a non-`is:inline` head script**
  when the effect must re-apply after navigation (theme toggle, analytics page
  view).

### Island Architecture

- **Use the most restrictive `client:*` directive that works.**
  `client:visible` > `client:idle` > `client:load`. Only use `client:load` when
  the component must hydrate immediately (above-the-fold interactive).
- **No `client:*` on purely static components.** Astro ships zero JS by default;
  adding a client directive opts in to hydration.
- **`client:only="<framework>"` for components that cannot SSR** (browser-only
  APIs, framework-specific context). Always pass the framework string.

### Content Collections

- **Define collection schemas in `src/content/config.ts`** using Zod. Untyped
  collections lose frontmatter validation.
- **Query collections via `getCollection()` / `getEntry()`** — never raw
  `import.meta.glob` on content directories.
- **Slug collisions are silent** — two files with the same slug in one
  collection produce undefined behavior. Name files distinctly.

### Layout and Components

- **Layouts receive `Astro.props`** (frontmatter fields) and `<slot />` for
  content — never re-parse the child's frontmatter manually.
- **Sidebar/nav scroll preservation** requires `position: sticky` +
  `overflow-y: auto` + a `max-height` constraint — `transition:persist` then
  retains the scroll offset across navigations.
- **Scoped styles are the default.** Use `is:global` only when the style must
  escape the component boundary (theming, third-party DOM).

### Accessibility

- **`aria-current="page"` on nav links matching `Astro.url.pathname`** — set
  server-side AND re-sync in `astro:after-swap` for persisted navs.
- **View-transition animations honor `prefers-reduced-motion`** — wrap
  transition CSS in `@media (prefers-reduced-motion: no-preference)`.

## Apply or Report

- **Auto-fixable** (mechanical) → apply silently, note in the commit message.
- **Requires judgment** → surface as a suggestion before committing: what the
  finding is, where, and a concrete fix sketch.
- **Conflicts with project config** → suppress; never fight the linter.

## Common Mistakes

- Adding `<ClientRouter />` without `transition:persist` on stateful elements —
  client-side swap works but scroll position resets on every navigation.
- Forgetting `astro:after-swap` sync — `aria-current` and active classes go
  stale on persisted elements after navigation.
- Using `client:load` everywhere — defeats Astro's zero-JS default; most
  components need `client:visible` or `client:idle` at most.

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument
(e.g., `wk-learn workstyle-astro`).
