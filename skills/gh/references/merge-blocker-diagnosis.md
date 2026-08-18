---
class: reference
---

# Merge-blocker diagnosis — remediation catalog

Companion to `SKILL.md`'s green-checks `BLOCKED` checklist. The checklist decides
*what* is blocking; these rows cover what to do about a blocker you cannot satisfy
directly.

## Missing context owned by an external integration

- Use only the integration's documented rerun surface.
- `requested_reviewers` returns 422 for non-collaborator integrations, and an
  imagined GraphQL mutation cannot trigger a run.
- No supported API → name the missing context and hand the UI action to the user.

## Unsigned commit mid-range under `required_signatures`

- The offending commit usually arrives via a merge from a branch carrying an
  unsigned direct push (commonly CI or bot automation), so it is neither the head
  nor authored locally.
- Recreating the commit objects is the fix, not re-pushing: a rebase whose target
  already equals the merge-base no-ops silently. See `wk-pr-update` Stage 3b.
