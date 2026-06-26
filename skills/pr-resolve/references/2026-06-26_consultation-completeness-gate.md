---
class: principle
---

**Rule:** A Step 5 judgment-required consultation message must restate the full
§4 suggestion block for its single item — the original comment body or a direct
quote, the proposed fix, and the skip rationale. A bare letter/code reference
("A+C, D, B") is unreadable to the user, so the count gate passing is necessary
but not sufficient.

**Why:** The pre-emit gate previously counted only `Comment {n}` headers — a
valid one-item message can still omit essential context if the agent summarizes
items as letters/codes instead of restating them. The user then cannot interpret
the prompt and must ask for clarification, stalling the consultation. Counting
headers verifies structure (one item per message); it does not verify content.
Promoted the gate from count-only to count + completeness so each item carries
enough context to decide on.

**Where:** wk-pr-resolve Step 5 pre-emit gate (now two mechanical checks: count
and completeness). Consolidated the duplicated Step 4 re-tag sentence into the
Step 5 partition rule to offset the addition under the body-size ceiling.
