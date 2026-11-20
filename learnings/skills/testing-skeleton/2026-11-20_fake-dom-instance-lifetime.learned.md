---
skill: wk-testing-skeleton
date: 2026-11-20
type: correction
severity: high
verified-against-source: yes
---

A hand-rolled fake DOM that reuses one controller instance across page renders hid a state-lifetime bug.

**What happened:** A body-level Stimulus controller stored a "this is a Back/Forward visit" flag on its instance.
Turbo Drive replaces `<body>` on every render, so a fresh instance connects and never sees the flag. The fake-DOM
test harness dispatched the visit, before-render and load events against the same instance, so the tests passed.
Two review rounds marked the fix "tested" before a fresh adversarial reviewer read the framework's renderer and
caught it.

**Root cause:** The harness did not model the framework's element lifecycle: disconnect the old element, connect a
new one. Verified against the renderer source, where the body element is replaced on every page render.

**Suggested fix:** When a test fakes a framework's event sequence, model its object lifecycle too: which instances
are torn down and rebuilt between events. Add a negative control showing the test fails when state is kept on the
instance. Any state that must survive a render belongs in module scope or the document, never on the instance.
