---
skill: wk-workstyle-astro
date: 2026-08-18
type: pattern
severity: medium
verified-against-source: yes
---

Astro view transitions for docs sites: ClientRouter + transition:persist + aria-current sync

**What happened:** A docs site with sidebar navigation caused full page reloads on every nav click, resetting scroll position. Adding `<ClientRouter />` alone enabled client-side swaps but the sidebar DOM was still replaced on each navigation, losing scroll state.

**Root cause:** Three independent concerns: (1) Astro static sites do full-document navigations by default — `ClientRouter` from `astro:transitions` enables client-side swap. (2) Even with client-side swap, Astro replaces the entire `<body>` — sidebar scroll position is lost unless the element is marked `transition:persist`. (3) A persisted element keeps its old DOM, so server-rendered attributes like `aria-current` go stale — manual sync is needed via `astro:after-swap`.

**Suggested fix:** When building a docs site with Astro view transitions, apply this pattern:

1. Add `<ClientRouter />` from `astro:transitions` to the layout `<head>`.
2. Add `transition:persist` to the sidebar/nav container whose scroll state should survive navigation.
3. Add an `astro:after-swap` listener to update `aria-current` (or any server-rendered active-state indicator) on persisted nav links by comparing `location.pathname` to each link's `href`.
4. `is:inline` scripts in `<head>` re-run on every client-side navigation — correct for theme-restore scripts that must apply before paint.
5. The sidebar nav should already have `position: sticky` + `overflow-y: auto` + `max-height` for independent scrolling — `transition:persist` then preserves that scroll position.
6. Verify client-side swap (vs full reload) by setting `window.__testMarker` before a click and checking it survived after navigation.
