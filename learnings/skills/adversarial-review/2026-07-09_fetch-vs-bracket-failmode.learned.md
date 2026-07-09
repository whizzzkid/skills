---
skill: wk-adversarial-review
date: 2026-07-09
type: pattern
severity: medium
---

Issue class: hash-access fail-mode (`.fetch(k)` vs `h[k]`) on a required field — and an automated reviewer flip-flopping on it across rounds.

**What happened:** A shared counting helper read a required `severity` field. Round 1 the {bot} flagged `h["severity"]` as unsafe (silently returns nil → miscounts, treated as fail-open bug). After switching to `.fetch("severity")`, a later round the same {bot} flagged the `.fetch` as a "behavioral regression" because it now raises `KeyError` on malformed input (fail-fast). The two findings directly contradict each other on the same line.

**Root cause:** Whether fail-open or fail-fast is correct depends on a design invariant the reviewer cannot see from the diff alone: is the field schema-guaranteed? When it is (producer always emits it; siblings already use `.fetch`), fail-fast is right — a missing key is corrupt data that must surface, not silently skip a gate. A line-local reviewer re-derives the opposite conclusion each pass.

**Detection sketch:** On a `.fetch(k)`-vs-`h[k]` finding, resolve it by (1) grepping siblings in the same module/file for the established access convention, and (2) checking whether the field is schema-guaranteed (producer/JSON-schema doc). Convention + guarantee present → fail-fast (`.fetch`) is correct; dismiss the fail-open finding. Also: when the same automated reviewer re-fires on a line it previously pushed you to change, treat the contradiction as a signal to stop flipping the code and dismiss with the invariant cited — do not oscillate.

**Confidence:** high — grep for sibling access pattern + schema doc is decisive; the flip-flop is a known automated-reviewer failure mode on fail-mode judgment calls.
