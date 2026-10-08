# Bats / Shell Test Patterns

## Propagate failure from non-final Bats assertions

A `[[ ... ]]` that fails mid-test does not abort the test function — subsequent
commands succeed and Bats reports green, so the broken assertion is invisible.
Append `|| return 1` to every `[[ ... ]]` when more commands follow in the same
test:

```bash
[[ "$output" == *"expected"* ]] || return 1
[[ "$status" -eq 0 ]]
```

Mutation-verify by breaking the early assertion and confirming the test fails.

## Assert a literal tilde with a quoted glob, not a regex

An unquoted leading `~` on the right of a bash `[[ =~ ]]` is tilde-expanded to
`$HOME` before the regex runs, so a pattern meant to match a literal tilde — or a
tilde-prefixed home path (a yarnrc dotfile, say) — instead matches the expanded
`$HOME` value, and the assertion passes or fails for the wrong reason.

- Assert a literal-tilde string with a quoted glob so no expansion happens:
  `[[ "$output" == *'~'* ]]`; quote any tilde-prefixed path segment the same way.
- When the substring can match a superset, add a negative assertion excluding it.

## Capture args inside the loop in fake shell-binary stubs

When a fake binary (a stub `curl`/`git`/etc. on `PATH`) logs its invocation by
parsing positional args in a `while [[ $# -gt 0 ]]; do ... shift; done` loop,
`echo "$@"` placed **after** the loop always emits nothing — `shift` consumes
`$@` in place, so it is empty once the loop exits. The log file is never written
and tests fail with a missing-file error instead of a useful assertion.

- Capture the value into a named variable **inside** the loop (e.g. `api_url="$1"`
  in the wildcard `case` branch), then read that variable after the loop.
- Never rely on `$@` / `$1` surviving a complete shift-consuming loop.

## Pass harness payloads through the environment, never string interpolation

A fixture that interpolates the input under test into a shell command string
cannot represent input containing a quote character — the input's own quote closes
the wrapping quote and silently mangles the payload before the artifact ever sees it.

- Export the payload and read it inside the child process instead of building the
  command text around it: `PAYLOAD=… run bash -c 'printf %s "$PAYLOAD" | "$1"' _ "$TOOL"`.
- The corruption fails open-looking — the case reports a plausible assertion failure
  rather than an error, so it reads as evidence about the code, not about the fixture.
- A newly added case failing while every pre-existing case passes indicts the harness
  first: re-run the same input against the artifact directly before changing the
  implementation. Disagreement means the fixture is the defect.
