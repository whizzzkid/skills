---
class: one-off
---

**Scenario** — User asks to "update the plan/doc to mark items done" or similar.

**Symptom** — Agent posted a PR comment about the items instead of changing the
artifact; user re-asked, wanting the doc content itself edited.

**Fix** — Treat "update/mark in the plan/doc" as an edit to the source file's
body. Use a comment only when the user explicitly asks to comment.

**Why not promoted** — Low-severity, narrow intent-disambiguation; a single
bullet in the body would not survive the size ceiling against higher-value rules.
