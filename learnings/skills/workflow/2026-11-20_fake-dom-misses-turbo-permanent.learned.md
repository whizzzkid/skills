---
skill: wk-workflow
date: 2026-11-20
type: surprise
severity: high
verified-against-source: yes
---

A hand-rolled fake DOM passed a live-region feature that the real browser broke twice; Phase 3.6 browser verification caught both.

**What happened:** Controller tests modelled a Turbo body swap but not `data-turbo-permanent` handling. In the real browser, mid-render Turbo parks the permanent node behind a `<meta name="turbo-permanent-placeholder">`, so the region lookup at connect time returned null. A second bug: page and frame announcements produced two concatenated sentences.

**Root cause:** Test harness fidelity gap: the fake render never parked permanent nodes. Confirmed by reading turbo.js Bardo and by the live browser repro.

**Suggested fix:** For any UI change relying on framework lifecycle (Turbo permanent nodes, frame busy state, morphing), drive it in a real browser before the first commit of the wiring, then add the browser-observed lifecycle step to the fake harness as a regression test.
