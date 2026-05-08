# Subagent Contract & MCP Pattern — Shared Reference

Used by: `wk-goodmorning`, `wk-goodevening`, `wk-self-perf`.

---

## Subagent Contract (prepend verbatim to every dispatched agent prompt)

```
SUBAGENT CONTRACT (mandatory):
- Return STRUCTURED DATA ONLY — do not write files, run git commands, or commit
- Do NOT invoke /skills or act as the orchestrator skill
- Do NOT prompt the user for input — the orchestrator handles all triage
- Do NOT open files in browsers or call `open`
- Your output is markdown text the orchestrator pastes into a section
- EVERY item you return that could become a priority MUST include a
  source identifier: a URL, MCP deep link, file path, or
  `{system}:{id}` reference. Items without a source identifier will
  be rejected at compile time. If the item came from a meeting note,
  return the meeting URL or ID alongside the extracted insight; if
  from a Slack message, return the permalink; if inferred, mark
  `(inferred)` and list the source artifacts the inference used.
- Distinguish verified facts from single-source claims. Tag each
  item `verified` (concrete artifact like a calendar invite, Jira
  ticket, PR URL, explicit announcement) or `claim` (extracted from
  someone's offhand remark in a meeting/DM and not cross-checked).
  The orchestrator uses this to choose render styling and conflict
  detection.
```

After agents return, the orchestrator must verify git state (no unexpected commits,
no uncommitted files outside the session's intended paths). A subagent that overran
its scope will show up here; if found, discard its output and re-dispatch.

---

## MCP Connection Pattern (all agents follow this)

1. `ToolSearch` to find MCP tools for the service.
2. Call the authenticate tool to start OAuth.
3. After auth completes, use the operational tools.
4. **If auth fails (OAuth URL returned)** → return a **SOFT BLOCK**:
   `"SOFT_BLOCKED: {Service} needs authorization at: {url}"`
5. **If no MCP tools found or missing secret** → return a **HARD BLOCK**:
   `"HARD_BLOCKED: {Service} MCP tools not configured. User must install the MCP server."`

### Soft vs. Hard Blockers

| Type | Example | Behavior |
|------|---------|----------|
| **Hard** | MCP not installed, missing secret | Stop output; list all hard blocks; require user fix before continuing |
| **Soft** | OAuth URL returned | Continue with degraded data; embed the authorization URL in the affected section; note in summary |

If ANY hard block occurs, pause and present all hard blocks at once:

> "The following services need your attention before I can continue:
>
> 1. {Service}: {reason and action needed}
>
> Please fix these and tell me to continue."

If only soft blocks occur, proceed. For each soft-blocked service:
- Use the most recent available brief (morning.md / evening.md) as fallback data.
- Embed the authorization URL as a prominent **⚠ Authorize {Service}** CTA.
- List the soft block in the final summary so the user knows the section is degraded.
- After the user fixes access, re-run only the failed agents.

---

## `+m` Modifier (remember as weekly rule)

Any per-item or batch-level choice can have `+m` appended to save it as a
weekly memory rule:

| Input | Effect |
|-------|--------|
| `2c+m` | Skip item 2 AND add an auto-skip rule to weekly memory |
| `3a+m` | Will do item 3 AND add an auto-will-do rule to weekly memory |
| `all:c+m` | Skip entire batch AND add auto-skip rules for all items |

### Pattern-Extraction Table

When `+m` is used, extract the **pattern** (not the specific instance) and
write it to `$WEEK_MEMORY`. Patterns are derived from the item's distinguishing
attributes:

| Item type | Pattern extracted |
|-----------|-----------------|
| Slack message | Channel name (e.g., "skip all from #alerts") |
| Email | Sender or subject pattern (e.g., "skip newsletters from noreply@") |
| GitHub PR/Issue | Repository name (e.g., "always will-do PRs from repo-x") |
| Jira ticket | Project key (e.g., "skip mentions from PROJECT-Y") |
| Confluence | Space name (e.g., "skip announcements from Engineering space") |
| Carry-over / action item | Source meeting or thread (e.g., "always carry-forward from standup") |

Confirm inline after extracting the pattern:

> "Saving weekly rule: **auto-{action} items from {pattern}**.
> This will apply to all future items matching this pattern this week."

If the user says "no" or "cancel", apply the action but don't save the rule.

---

## Service Connection Summary Row Schema

Each row in a Service Connection Summary table follows this schema:

| Column | Content |
|--------|---------|
| Service | Friendly name |
| ToolSearch | Query string to pass to `ToolSearch` |
| Agent | Agent number (1-N) that owns this service |
| Fallback | `gh` CLI, prior brief, or `**BLOCKED** — require MCP` |
