---
name: wk-curl
description: >-
  Use whenever invoking curl to call an HTTP/HTTPS endpoint whose response is
  parsed or whose success matters — REST APIs, webhooks, health checks, file
  downloads. Enforces transport-error-safe flags, exit-status capture, and
  token hygiene. Auto-invoked whenever the agent is about to run a curl command.
argument-hint: '(model-invoked; no arguments)'
allowed-tools:
  - Bash
  - Read
model: sonnet
effort: low
model-invocable: true
user-invocable: true
license: MIT
group: tools
metadata:
  author: whizzzkid
  version: "2026.07.28-171037"
  model:
    openai: gpt-5.6-terra
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-1.5
---

# curl

Safety idioms for calling HTTP endpoints with `curl` when the response is
parsed or the call's success matters. Auto-loaded whenever the agent is about
to run a curl command.

## HARD RULE — `-sS`, never bare `-s`, on any parsed call

`-s` (silent) and `-S` (show errors) are orthogonal flags:

- `-s` alone suppresses the progress meter **and** curl's own transport-error
  diagnostic (DNS failure, TLS error, connection refused). On transport failure
  stdout is empty, so downstream parsing emits a misleading empty-reason error.
- `-sS` suppresses only the progress meter; transport errors still print to
  stderr.

Use `-sS` for every call whose output is parsed. Bare `-s` is the anti-pattern.

## HARD RULE — capture and branch on the exit status

A curl that fails to connect still exits non-zero with empty stdout. Capture
`$?` immediately and branch on it **before** parsing the body — otherwise a
transport failure is misreported as an API error.

```bash
RESPONSE=$(curl -sS -X <METHOD> "<URL>" -H "Authorization: Bearer $TOKEN" -d "$PAYLOAD")
CURL_EXIT=$?
if [ "$CURL_EXIT" -ne 0 ]; then
  echo "Network error (curl exit $CURL_EXIT) — see stderr above"
elif [ -z "$(echo "$RESPONSE" | jq -r '.web_url // empty')" ]; then
  echo "API error: $(echo "$RESPONSE" | jq -r '.message // empty' || echo "$RESPONSE")"
else
  : # success path
fi
```

Branch order is fixed: non-zero exit → transport failure (curl already printed
the reason); zero exit + missing expected field → API-level error.

## HARD RULE — keep secrets off the command line

A token passed inline (`-H "Authorization: Bearer abc123"`) is visible in the
process table (`ps`) and shell history to any local user. Pass secrets via an
environment variable referenced inside the quoted header (`-H "Authorization:
Bearer $TOKEN"`), or via `--config -` / a `@file` on a restricted path. Never
hardcode a literal token in the command.

## Quick Reference

| Situation | Rule |
|---|---|
| Response is parsed | `curl -sS …`, never bare `-s` |
| Call can fail at the transport layer | Capture `$?`, branch before parsing body |
| Request carries a credential | Reference `$TOKEN` in the header; never inline the literal |
| `-w` for status code | `curl -sS -o body.txt -w '%{http_code}'` to separate body from status |

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument (e.g., `wk-learn curl`).
