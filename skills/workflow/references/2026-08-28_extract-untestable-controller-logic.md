---
class: principle
skill: wk-workflow
source: learnings/skills/workflow/2026-08-28_extract-untestable-controller-logic.md
date: 2026-08-28
---

## Principle

When adding branch logic to a component, assess which branches the existing
test harness can exercise. Branches unreachable by the harness (client-only
state transitions in a server-rendered spec, in-memory collisions, fragment
parsing) must be extracted into a pure module with unit tests in the same task.

## Failure Mode

Logic added inline in a controller gained branches the spec harness
structurally could not reach — a review round forced a mid-cycle refactor
to extract and unit-test the pure logic.

## Landing

Added "Test-harness reachability" bullet to Phase 2 Edit-scope pre-flights.
