---
class: principle
---

**Rule** — When a helper is extracted from a function that accepts a `context.Context`, grep the helper body for `context.Background()`/`context.TODO()`. Any such call inside a helper invoked by a context-accepting function is a candidate dropped propagation. Confirm every error-switch `case errors.Is(err, context.Canceled)` is reachable — an unreachable case signals the context was never plumbed through. Fix by adding `parentCtx context.Context` as the helper's first param with a `nil → context.Background()` guard.

**Why** — An extraction that moves `context.WithTimeout` into the helper and defaults to `context.Background()` silently drops caller-supplied cancellation (SIGINT, timeout). The refactor looks complete (same timeout, same args), but parent-context wrapping and the nil-guard are dropped without a direct test exercising the Canceled path.

**Where** — Sweep 2.52. Any subprocess/helper extraction in a context-aware codebase.
