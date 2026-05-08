---
skill: wk-pr-resolve
date: 2026-05-08
type: correction
severity: medium
---

Obvious-fix items presented as per-comment consultation instead of bulk-apply preview.

**What happened:** A finding tagged `obvious-fix` (skip rationale: "no valid reason to skip") was presented with the full `(a)/(e)/(d)/(s)` per-comment consultation prompt. The user had to manually select `a`, which is exactly the ceremony the bulk-apply flow is designed to eliminate.

**Root cause:** The agent generated the suggestion block with the classification tag but then fell through into the per-comment consultation loop anyway, bypassing the Step 5 branch that routes `obvious-fix` items to the bulk-apply preview. The classification was correct; the routing was not applied.

**Suggested fix:** After completing all Step 4 suggestions, explicitly partition into two lists before entering Step 5: `obvious_fixes[]` and `judgment_required[]`. Only emit the per-comment loop for `judgment_required`. For `obvious_fixes`, emit the bulk-apply preview block and gate on a single confirmation. Never emit a `(a)/(e)/(d)/(s)` prompt for an item whose skip rationale contains "no valid reason" — re-read the rationale immediately before emitting any Step 5 prompt and re-route if needed.
