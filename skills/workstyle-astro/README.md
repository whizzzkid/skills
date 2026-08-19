# wk-workstyle-astro

**Version:** 2026.08.19-052846

Astro idiom enforcement — view transitions, island architecture, content
collections, and accessibility patterns for `.astro` files and `astro.config.*`.
Part of the [wk-workstyle](../workstyle/README.md) family.

## Triggers

- Auto: any `.astro` file edit, `astro.config.*` modification
- Manual: `/wk-workstyle-astro scan` or `/wk-workstyle-astro check <path>`

## Key Rules

- **View transitions:** `<ClientRouter />` + `transition:persist` on stateful
  elements + `astro:after-swap` to sync server-rendered attributes
- **Islands:** most restrictive `client:*` directive; no directive on static
  components
- **Content collections:** Zod schemas in `config.ts`, query via
  `getCollection()`/`getEntry()`
- **Head scripts:** `is:inline` for paint-blocking scripts that must re-run on
  navigation
- **Accessibility:** `aria-current="page"` server-side + after-swap sync;
  reduced-motion on transitions

## Integration

- Dispatched by [wk-workstyle](../workstyle/README.md) on `.astro` file edits
- Project `astro.config.*` is authoritative — skill fills gaps only
- Invokes [wk-learn](../learn/README.md) post-completion
