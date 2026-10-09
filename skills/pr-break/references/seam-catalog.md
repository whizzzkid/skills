# Seam catalog

A seam is a boundary where one side of the diff makes sense without the other. Categorize each candidate:

- **Infrastructure → primitives → feature** — feature decomposes as: (1) shared helper/type/migration, (2) the primitive
  using it, (3) the user-visible feature on top.
- **Refactor before behavior change** — moving/renaming code with no behavior change is its own PR; the behavior change
  lands on top of the cleaned-up shape.
- **Test scaffold before implementation** — fixtures, mocks, or a new test framework can land separately from the
  implementation that uses them; often the smallest, easiest reviewable PR.
- **Per-layer slices** — UI ↔ API ↔ DB. Each layer can often ship behind a feature flag; the user-visible surface flips
  on in the final child.
- **Per-feature slices** — multi-feature PRs rarely need to ship as one; split by user-visible capability, stack by
  dependency.
- **Cleanup last** — removing dead code, deprecated paths, or stale tests goes in the **final** child, once everything
  depending on the old shape has shipped through earlier children.

Bad seam = requires both sides to merge for either to make sense. Reject those.
