---
class: principle
---

**Rule** — A no-op `.catch()` is acceptable only on a fire-and-forget/background
promise (e.g. cache revalidation) whose caller already returned a value. Never
swallow the return-path promise a downstream fallback awaits — leave it able to
reject.

**Why** — Swallowing the return-path promise silently kills the downstream
fallback (offline/error path) that depends on the rejection propagating. The
existing "never `.catch(() => {})` silently" rule was absolute; this names the one
legitimate exception and its failure mode.

**Where** — wk-workstyle-async → sub-bullet under "Propagate errors from async
operations".
