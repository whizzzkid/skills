---
skill: wk-adversarial-review
date: 2026-07-10
type: pattern
severity: medium
---

A "replace T.untyped with a precise type" finding can be infeasible when the framework's RBI doesn't type the member the body calls on that type.

**What happened:** An automated reviewer flagged a method signature as `T.untyped`-imprecise and suggested `T.class_of(Rails::Engine)` for both the param and return. Applying it to the param broke the type-checker: the method body calls a class-level accessor (`.middleware`) that the framework's RBI never declares on the engine's singleton (it is added at runtime by a mix-in), and the repo's linter forbade `T.unsafe` to bridge the gap. Only the return type could be tightened cleanly, because the returned value flows out without a member access.

**Root cause:** Type-precision findings are validated against the *concept* ("this could be more specific") without checking that the proposed type actually exposes, in the type-checker's stubs, every member the body dereferences. Runtime-added accessors (metaprogrammed by framework mix-ins) are the common blind spot.

**Suggested fix:** Before accepting/applying a type-precision finding, verify the proposed type exposes the members the body uses in the type stubs (RBI/`.d.ts`/etc.). If it does not and escape hatches (`T.unsafe`/`any`-casts) are banned by the linter, apply precision only to the half that works (often the return type or a value that flows out untouched) and record why the other half stays loose. Confirm the type-checker AND linter both pass — a green test suite does not prove a tightened signature compiles.
