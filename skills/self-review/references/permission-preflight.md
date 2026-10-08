# Permission Pre-flight Details (Step 0.5)

Pending review created via `POST repos/{owner}/{repo}/pulls/{n}/reviews` under
the user's identity. In auto mode the permission classifier blocks GitHub writes
lacking an explicit allow rule — and blocks at Step 4, after the payload is
built → wastes the work.

## Check the write permission before building the payload

```bash
grep -rE 'gh api repos/.*/pulls/.*/reviews' $HOME/.claude/settings.json .claude/settings*.json 2>/dev/null
```

No match → surface a one-line prompt, then proceed (classifier still gates the
actual POST — this only warns early):

> Self-review posts a pending review via
> `gh api repos/*/pulls/*/reviews` (POST). Add that to allowed Bash
> commands to avoid a mid-flow block.

Never downgrade to a published `.../comments` call to dodge the prompt →
violates the pending-review HARD RULE.

## Payload authoring — Write tool by default

**HARD RULE: author the payload with the Write tool by default — never inline
review prose in a bash command.** Write it to
`/tmp/agent/gh/<owner>/<repo>/pulls/{n}/self-review.json`, then use bash only
for the POST (`--input <file>`, never `--input -` with a heredoc).

- A review body is arbitrary prose — slashes, regex literals, code snippets,
  URLs. Any PreToolUse gate that scans **command text** can read one of those
  tokens as a path or a denied endpoint and block before the command runs, so
  the composition is wasted for a reason the prose never intended.
- The Write path removes the exposure rather than dodging one matcher: the
  command carries a filename and no prose, so there is nothing left to scan.
  Never re-word a comment body to satisfy a gate's pattern — that tunes to one
  matcher and leaves every other body a coin flip.
- This is the default, not a recovery step. A rule that fires only *after* a
  block cannot prevent the block.

## Blocked POST recovery

Blocked POST → the payload file already exists; hand the user the one-line
`gh api … --input <file>`. Never rebuild the payload in a bash command that
mentions the blocked endpoint (`gh api repos/*/pulls/*/reviews`) — the
classifier matches command text, not execution, so even a `jq … > file.json`
write re-trips the same denial.
