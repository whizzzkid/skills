---
class: principle
source: learnings/skills/testing-skeleton/2026-11-20_fake-dom-instance-lifetime.learned.md
date: 2026-11-20
skill: wk-testing-skeleton
---

**Rule** — When a test fakes a framework's event sequence, also model the framework's object lifecycle: which
instances are torn down and rebuilt between those events. Add a negative control that keeps the cross-event state on
the instance and must fail. State that must survive a rebuild lives in module scope or the document.

**Why** — A body-level controller kept a "history-navigation visit" flag on its instance. The framework's renderer
replaces the body element on every page render, so a fresh instance connected and never saw the flag. The hand-rolled
fake DOM dispatched every event against one reused instance, so the tests passed; two review rounds called the fix
tested until a reviewer read the renderer source.

**Classification** — `principle`, new Stage 3 rule (the boundary-fake contract rule covers call signatures and return
shapes, not instance lifetime).

**Where** — `SKILL.md` → Stage 3 (Write the tests); README Noteworthy.
