---
class: principle
---

**Report** — Reviews ran several times per session: "an absolute waste of time and
tokens". The ask: one run on the complete change, when the work is ready to be
reviewed on the PR.

**Root cause** — The contract already said "run once per feature" and "one
re-review per session", but *ownership* was never assigned, so every caller read
those limits as applying to itself. Six skills each held their own dispatch: the
workflow gate, the PR gate after ready, the resolve step after every push, the PR
review's investigation phase, the takeover's pre-push clearance, and the merge
step's backstop. Each was individually "once" and collectively N.

**Principle** — A shared, expensive gate needs a named owner, not a per-caller
frequency limit. State which caller may dispatch and require every other caller to
read the recorded verdict; a missing record means "not yet at the gate", never a
licence to run.

**Landed as** — Contract item 3 (one dispatch, owned by the completion gate) and
item 4 (delta-scoped single re-review, waiver final), replacing four overlapping
items. Callers were retargeted to read the record: resolve and takeover push
ungated, review consumes an existing record and dispatches only when reviewing
another author's PR, and merge returns missing clearance to the completion gate.

**Generalizes to** — Any cross-skill gate whose cost scales with dispatch count
(full-suite runs, deep-research sweeps, paid API passes): assign the dispatch to
the step where the work is complete, and make every earlier step a reader.
