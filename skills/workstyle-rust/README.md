# wk-workstyle-rust

> Rust-specific code-quality gate for `.rs` files. Part of the [`wk-workstyle`](../workstyle/README.md) family.

**Version:** `2026.07.08-175435`

## Invocation

| Mode | Trigger |
|------|---------|
| Model-invocable | Automatic whenever the agent writes or edits a `.rs` file |
| User-invocable | `/wk-workstyle-rust scan` — full tree; `/wk-workstyle-rust check <path>` — one file |

## Rules at a Glance

- No `.unwrap()` / `.expect()` in production code paths — propagate with `?` or match.
- Prefer `&str` over `String` for parameters that don't need ownership.
- Derive `Debug` on all public types.
- `clippy::all` passes before commit.
- Document public items with `///`; include an `# Examples` section for non-trivial items.

## Noteworthy

- **Project config is always authoritative.** Defers to any active linter /
  formatter config; fills gaps only.
- **Part of the [`wk-workstyle`](../workstyle/README.md) family** — the [`wk-workstyle`](../workstyle/README.md) orchestrator runs
  the shared project-style-authority probe (Step 0) and routes to this skill
  based on the touched files / change type. This skill is also independently
  model-invocable on adjacent work.
- `.unwrap()`/`.expect()` are banned in production paths — propagate with `?` or `match`.
- Public types derive `Debug`; public items carry `///` docs with an `# Examples` section.
