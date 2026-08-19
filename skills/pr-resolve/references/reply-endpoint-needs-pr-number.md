---
class: principle
escalation: "rung 1 → rung 2 (already-covered re-violation)"
---

**Rule** — The inline review-comment reply endpoint requires the PR number as a path segment: `repos/{owner}/{repo}/pulls/{number}/comments/{id}/replies`. Omitting `{number}` returns a generic 404 with no diagnostic hint.

**Why** — The agent composed the endpoint from memory, dropping the `{number}` segment despite the correct template existing in commands.md §8. The command template alone was insufficient to prevent the omission.

**Where** — `references/commands.md` → Step 8 → reply-posting block (escalated to `**Important:**`).
