---
skill: wk-adversarial-review
date: 2026-06-16
type: gap
severity: low
---

New function-level doc comment conflated two independent concerns, making it misleading.

**What happened:** A refactored function was given a new doc comment explaining both (a) why it now returns an extra value and (b) an unrelated implementation detail about a file being written to disk. The comment phrased the disk-write as a precondition for the in-memory return, which was incorrect — the two are independent.

**Root cause:** When writing a new comment for a changed function, it is tempting to explain *all* reasons the design was chosen in a single clause. This conflates motivations that belong in separate sentences, producing a comment that misleads readers about the causal relationship.

**Suggested fix:** Sweep 2.4 (comment accuracy) should specifically check for doc comments on newly-added or significantly-changed functions where a single sentence contains multiple independent "because / while / so that" clauses. Each distinct reason should stand alone. Prompt: "Does removing either clause change the meaning of the other? If not, they describe independent concerns and should be split."
